from __future__ import annotations

from typing import Any

from PySide6.QtCore import Property, QObject, Signal, Slot

from sys_assistant.config.app_config import AppConfig
from sys_assistant.core.monitor import SystemMonitor
from sys_assistant.managers.cleanup_manager import CleanupManager
from sys_assistant.managers.health_checker import HealthChecker
from sys_assistant.managers.performance_manager import PerformanceManager
from sys_assistant.managers.process_manager import ProcessManager
from sys_assistant.services.autostart_service import AutostartService
from sys_assistant.services.logger_service import LoggerService
from sys_assistant.services.polling_service import PollingService


class SysAssistantBridge(QObject):
    statsUpdated = Signal("QVariant")
    actionCompleted = Signal(str, "QVariant")
    processesUpdated = Signal("QVariant")

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        self.logger = LoggerService()
        self.config = AppConfig()
        self.monitor = SystemMonitor()
        self.process_manager = ProcessManager(logger=self.logger)
        self.performance_manager = PerformanceManager(logger=self.logger)
        self.cleanup_manager = CleanupManager(logger=self.logger)
        self.health_checker = HealthChecker()
        self.autostart = AutostartService()

        self._stats: dict[str, Any] = self._default_stats()
        self._polling = PollingService(
            self.monitor,
            interval_ms=int(self.config.get("update_interval_ms", 1000)),
        )
        self._polling.statsUpdated.connect(self._on_stats_polled)

        profile = self.performance_manager.get_current_profile()
        self.monitor.set_power_profile(profile)

    def start_polling(self) -> None:
        self._polling.start()

    def _on_stats_polled(self, stats: dict) -> None:
        stats["power_profile"] = self.performance_manager.get_current_profile()
        self._stats = stats
        self.statsUpdated.emit(stats)

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

    @Property("QVariant", notify=statsUpdated)
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
        return self.performance_manager.get_status()

    @Slot(result="QVariant")
    def runSystemCheck(self):
        result = self.health_checker.run_system_check()
        self.actionCompleted.emit("system_check", result)
        return result

    @Slot(result="QVariant")
    def getThumbnailCacheSize(self):
        return self.cleanup_manager.get_thumbnail_cache_size()

    @Slot(result="QVariant")
    def cleanThumbnailCache(self):
        result = self.cleanup_manager.clean_thumbnail_cache()
        self.actionCompleted.emit("clean_cache", result)
        return result

    @Slot(result="QVariant")
    def getSettings(self):
        settings = self.config.as_dict()
        settings["autostart_active"] = self.autostart.is_enabled()
        icon_pos = settings.get("floating_icon", {})
        return settings

    @Slot(str, "QVariant", result="QVariant")
    def updateSetting(self, key: str, value):
        if key == "autostart":
            result = self.autostart.enable() if value else self.autostart.disable()
            self.config.set("autostart", bool(value))
            self.actionCompleted.emit("update_setting", {"ok": True, "key": key, "value": value})
            return result

        if key == "update_interval_ms":
            self._polling.set_interval(int(value))

        if key == "floating_icon":
            current = self.config.get("floating_icon", {})
            if isinstance(current, dict) and isinstance(value, dict):
                current.update(value)
                self.config.set("floating_icon", current)
                return {"ok": True, "message": "Đã lưu vị trí icon."}

        self.config.set(key, value)
        return {"ok": True, "message": f"Đã cập nhật {key}."}

    @Slot(int, int)
    def saveIconPosition(self, x: int, y: int):
        self.updateSetting("floating_icon", {"x": x, "y": y})

    @Slot(result="QVariant")
    def getIconPosition(self):
        pos = self.config.get("floating_icon", {"x": 100, "y": 100})
        return pos
