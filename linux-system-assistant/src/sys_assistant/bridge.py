from __future__ import annotations

import os
from typing import Any

from PySide6.QtCore import Property, QCoreApplication, QObject, QRunnable, QThreadPool, QTimer, Signal, Slot
from PySide6.QtGui import QGuiApplication

from sys_assistant.config.app_config import AppConfig
from sys_assistant.core.monitor import SystemMonitor
from sys_assistant.managers.cleanup_manager import CleanupManager
from sys_assistant.managers.health_checker import HealthChecker
from sys_assistant.managers.performance_manager import PerformanceManager
from sys_assistant.system_tools.system_check import SystemChecker
from sys_assistant.system_tools.cleanup import CleanupScanner
from sys_assistant.system_tools.hardware_info import HardwareInfoCollector
from sys_assistant.managers.process_manager import ProcessManager
from sys_assistant.services.autostart_service import AutostartService
from sys_assistant.services.logger_service import LoggerService
from sys_assistant.services.polling_service import PollingService


class _AsyncTaskSignals(QObject):
    finished = Signal(str, "QVariant")  # type: ignore[arg-type]


class _AsyncTask(QRunnable):
    def __init__(self, action: str, callback, signal_parent: QObject | None = None) -> None:
        super().__init__()
        self.setAutoDelete(False)
        self.action = action
        self.callback = callback
        self.signals = _AsyncTaskSignals(signal_parent)

    def run(self) -> None:
        try:
            result = self.callback()
        except Exception as exc:  # pragma: no cover - defensive UI boundary
            result = {"ok": False, "message": f"Tác vụ lỗi: {exc}"}
        try:
            self.signals.finished.emit(self.action, result)
        except RuntimeError:
            # The app may be closing while a worker is finishing.
            return


class SysAssistantBridge(QObject):
    statsUpdated = Signal("QVariant")  # type: ignore[arg-type]
    actionCompleted = Signal(str, "QVariant")  # type: ignore[arg-type]
    processesUpdated = Signal("QVariant")  # type: ignore[arg-type]
    errorLogsUpdated = Signal("QVariant")  # type: ignore[arg-type]

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.logger = LoggerService()
        self.config = AppConfig()
        self.monitor = SystemMonitor()
        self.process_manager = ProcessManager(logger=self.logger)
        self.performance_manager = PerformanceManager(logger=self.logger)
        self.cleanup_manager = CleanupManager(logger=self.logger)
        self.health_checker = HealthChecker()
        self._system_checker = SystemChecker()
        self._cleanup_scanner = CleanupScanner()
        self._hw_collector = HardwareInfoCollector()
        self.autostart = AutostartService()

        self._stats: dict[str, Any] = self._default_stats()
        self._polling = PollingService(
            self.monitor,
            interval_ms=int(self.config.get("update_interval_ms", 1000)),
        )
        self._polling.statsUpdated.connect(self._on_stats_polled)

        self._poll_count = 0
        self._cached_power_profile = self.performance_manager.get_current_profile()
        self.monitor.set_power_profile(self._cached_power_profile)
        self._thread_pool = QThreadPool.globalInstance()
        self._async_busy: set[str] = set()
        self._async_tasks: dict[str, _AsyncTask] = {}

    def start_polling(self) -> None:
        self._polling.start()

    def _on_stats_polled(self, stats: dict) -> None:
        self._poll_count += 1
        # Only poll power profile every 10 seconds to save resources
        if self._poll_count >= 10:
            self._cached_power_profile = self.performance_manager.get_current_profile()
            self._poll_count = 0
            
        stats["power_profile"] = self._cached_power_profile
        self._stats = stats
        self.statsUpdated.emit(stats)
        self.errorLogsUpdated.emit(self.logger.recent_errors())

    @staticmethod
    def _default_stats() -> dict[str, Any]:
        return {
            "cpu": {"usage": 0, "temp": None, "freq_ghz": None},
            "gpu": {"usage": None, "temp": None, "name": "unavailable", "available": False},
            "ram": {"usage": 0, "used_gb": 0, "total_gb": 0},
            "disk": {"usage": 0, "used_gb": 0, "total_gb": 0},
            "network": {"download_mb_s": 0, "upload_mb_s": 0},
            "fan": {"speed_rpm": None},
            "battery": None,
            "power_profile": "unknown",
        }

    @Property("QVariant", notify=statsUpdated)  # type: ignore[arg-type]
    def stats(self):
        return self._stats

    @Slot(result="QVariant")
    def getStats(self):
        return self._stats

    @Slot(result="QVariant")
    def getTopProcesses(self):
        processes = self.process_manager.get_top_processes()
        self.processesUpdated.emit(processes)
        return processes

    @Slot(result=bool)
    def requestTopProcesses(self) -> bool:
        return self._run_async("top_processes", self.process_manager.get_top_processes)

    @Slot(int, bool, result="QVariant")
    def killProcess(self, pid: int, force: bool = False):
        result = self.process_manager.kill_process(pid, force=force)
        self.actionCompleted.emit("kill_process", result)
        return result

    @Slot(int, result=bool)
    def isProcessAlive(self, pid: int) -> bool:
        return self.process_manager.is_process_alive(pid)

    @Slot(str, result="QVariant")
    def setPowerProfile(self, profile: str):
        result = self.performance_manager.set_profile(profile)
        if result.get("ok"):
            self.monitor.set_power_profile(profile)
            stats = dict(self._stats)
            stats["power_profile"] = profile
            self._stats = stats
            self.statsUpdated.emit(stats)
        self.actionCompleted.emit("set_power_profile", result)
        return result

    @Slot(result="QVariant")
    def getPowerStatus(self):
        status = self.performance_manager.get_status()
        status["current"] = self._cached_power_profile
        return status

    @Slot(result="QVariant")
    def runSystemCheck(self):
        result = self._system_checker.run_system_check()
        self.actionCompleted.emit("system_check", result)
        return result

    @Slot(result=bool)
    def requestSystemCheck(self) -> bool:
        return self._run_async("system_check", self._system_checker.run_system_check)

    @Slot(result="QVariant")
    def scanCleanupTargets(self):
        result = self._cleanup_scanner.scan()
        self.actionCompleted.emit("scan_cleanup", result)
        return result

    @Slot(result=bool)
    def requestCleanupScan(self) -> bool:
        return self._run_async("scan_cleanup", self._cleanup_scanner.scan)

    @Slot("QVariant", bool, result="QVariant")
    def runCleanup(self, selected_ids, confirm_trash: bool = False):
        if hasattr(selected_ids, "toVariant"):
            selected_ids = selected_ids.toVariant()
        ids = list(selected_ids) if selected_ids else []
        result = self._cleanup_scanner.run_cleanup(ids, confirm_trash=confirm_trash)
        if result.get("cleaned_bytes", 0) > 0:
            self.logger.log_action("cleanup", f"cleaned={result.get('cleaned_label', '0 B')}")
        self.actionCompleted.emit("run_cleanup", result)
        self.errorLogsUpdated.emit(self.logger.recent_errors())
        return result

    @Slot("QVariant", bool, result=bool)
    def requestRunCleanup(self, selected_ids, confirm_trash: bool = False) -> bool:
        if hasattr(selected_ids, "toVariant"):
            selected_ids = selected_ids.toVariant()
        ids = list(selected_ids) if selected_ids else []
        return self._run_async(
            "run_cleanup",
            lambda: self._run_cleanup_worker(ids, confirm_trash),
        )

    def _run_cleanup_worker(self, ids: list, confirm_trash: bool = False) -> dict[str, Any]:
        result = self._cleanup_scanner.run_cleanup(ids, confirm_trash=confirm_trash)
        if result.get("cleaned_bytes", 0) > 0:
            self.logger.log_action("cleanup", f"cleaned={result.get('cleaned_label', '0 B')}")
        return result

    @Slot(result="QVariant")
    def getHardwareInfo(self):
        result = self._hw_collector.get_hardware_info()
        return result

    @Slot(result=bool)
    def requestHardwareInfo(self) -> bool:
        return self._run_async("hardware_info", self._hw_collector.get_hardware_info)

    @Slot(result=bool)
    def requestThumbnailCacheSize(self) -> bool:
        return self._run_async("get_thumbnail_size", self.cleanup_manager.get_thumbnail_cache_size)

    @Slot(result=bool)
    def requestCleanThumbnailCache(self) -> bool:
        def _clean_worker():
            result = self.cleanup_manager.clean_thumbnail_cache()
            if not result.get("ok", False):
                self.logger.warning(f"Cleanup failed: {result.get('message', 'unknown error')}")
            return result
        return self._run_async("clean_cache", _clean_worker)

    @Slot(result="QVariant")
    def getSettings(self):
        settings = self.config.as_dict()
        settings["autostart_active"] = self.autostart.is_enabled()
        icon_pos = settings.get("floating_icon", {})
        return settings

    @Slot(str, "QVariant", result="QVariant")
    def updateSetting(self, key: str, value):
        ALLOWED_SETTINGS = {
            "autostart", "update_interval_ms", "floating_icon", "theme",
            "show_temperature", "show_network_speed", "safe_mode_process_kill",
            "auto_hide"
        }
        if key not in ALLOWED_SETTINGS:
            self.logger.warning(f"Rejected setting update: {key}")
            self.errorLogsUpdated.emit(self.logger.recent_errors())
            return {"ok": False, "message": f"Cài đặt '{key}' không được phép thay đổi."}

        if key == "autostart":
            result = self.autostart.enable() if value else self.autostart.disable()
            if result.get("ok"):
                self.config.set("autostart", bool(value))
            self.actionCompleted.emit("update_setting", {"ok": True, "key": key, "value": value})
            return result

        if key == "update_interval_ms":
            interval = int(value)
            interval = max(500, min(10000, interval))  # Validate range
            self._polling.set_interval(interval)
            self.config.set(key, interval)
            return {"ok": True, "message": f"Update interval set to {interval}ms."}

        if key == "floating_icon":
            current = self.config.get("floating_icon", {})
            if isinstance(current, dict) and isinstance(value, dict):
                current.update(value)
                self.config.set("floating_icon", current)
                return {"ok": True, "message": "Đã lưu vị trí icon."}

        self.config.set(key, value)
        return {"ok": True, "message": f"Đã cập nhật {key}."}

    @Slot(result="QVariant")
    def resetSettings(self):
        """Reset all settings to defaults."""
        from sys_assistant.config.app_config import DEFAULT_CONFIG
        from copy import deepcopy

        self.config._data = deepcopy(DEFAULT_CONFIG)
        self.config.save()
        self._polling.set_interval(int(DEFAULT_CONFIG.get("update_interval_ms", 1000)))
        self.logger.log_action("reset_settings", "All settings reset to defaults")
        return {"ok": True, "message": "Đã khôi phục cài đặt mặc định."}

    @Slot(int, int)
    def saveIconPosition(self, x: int, y: int):
        self.updateSetting("floating_icon", {"x": x, "y": y})

    @Slot(result="QVariant")
    def getIconPosition(self):
        pos = self.config.get("floating_icon", {"x": 100, "y": 100})
        return pos

    @Slot(result="QVariant")
    def getErrorLogs(self):
        return self.logger.recent_errors()

    @Slot()
    def clearErrorLogs(self):
        self.logger.clear_recent_errors()
        self.errorLogsUpdated.emit(self.logger.recent_errors())

    def _run_async(self, action: str, callback) -> bool:
        if action in self._async_busy:
            return False
        self._async_busy.add(action)
        task = _AsyncTask(action, callback, signal_parent=self)
        self._async_tasks[action] = task
        task.signals.finished.connect(self._on_async_finished)
        self._thread_pool.start(task)
        return True

    @Slot(str, "QVariant")
    def _on_async_finished(self, action: str, result) -> None:
        self._async_busy.discard(action)
        self._async_tasks.pop(action, None)
        if action == "top_processes":
            self.processesUpdated.emit(result)
            return
        self.actionCompleted.emit(action, result)
        self.errorLogsUpdated.emit(self.logger.recent_errors())

    @Slot(result=bool)
    def quitApp(self) -> bool:
        app = QCoreApplication.instance()
        if app is None:
            return False
        self.logger.info("Application quit requested from UI")
        self._polling.stop()
        for window in QGuiApplication.topLevelWindows():
            window.close()
        QTimer.singleShot(0, app.quit)
        QTimer.singleShot(250, lambda: QCoreApplication.exit(0))
        QTimer.singleShot(1200, lambda: os._exit(0))
        return True
