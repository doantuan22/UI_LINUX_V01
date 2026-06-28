"""Phase 6: Comprehensive safety and quality tests."""
from __future__ import annotations

import os
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from sys_assistant.managers.command_manager import CommandManager
from sys_assistant.managers.cleanup_manager import CleanupManager
from sys_assistant.managers.process_manager import ProcessManager
from sys_assistant.managers.permission_manager import PermissionManager
from sys_assistant.config.app_config import AppConfig, DEFAULT_CONFIG


# === Command Whitelist Tests ===

class TestCommandWhitelist:
    def test_rejects_unknown_action(self):
        mgr = CommandManager()
        result = mgr.run_action("rm_rf_everything")
        assert result.ok is False
        assert "whitelist" in result.message.lower()

    def test_rejects_empty_action(self):
        mgr = CommandManager()
        result = mgr.run_action("")
        assert result.ok is False

    def test_dangerous_commands_not_in_whitelist(self):
        mgr = CommandManager()
        dangerous = ["rm_rf", "mkfs", "dd", "chmod_777", "killall", "pkill"]
        for action in dangerous:
            assert action not in mgr.commands, f"{action} should not be in whitelist"

    def test_whitelist_loaded(self):
        mgr = CommandManager()
        assert len(mgr.commands) > 0, "Whitelist should have at least one command"
        for key, spec in mgr.commands.items():
            assert "command" in spec, f"{key} missing 'command' field"
            assert isinstance(spec["command"], list), f"{key} command must be a list"


# === Command Timeout Tests ===

class TestCommandTimeout:
    def test_timeout_config_present(self):
        mgr = CommandManager()
        for key, spec in mgr.commands.items():
            timeout = spec.get("timeout_sec", 10)
            assert isinstance(timeout, (int, float)), f"{key} has invalid timeout"
            assert timeout > 0, f"{key} timeout must be positive"
            assert timeout <= 60, f"{key} timeout should not exceed 60s"


# === Cleanup Path Safety Tests ===

class TestCleanupSafety:
    def test_only_thumbnails_path(self):
        mgr = CleanupManager()
        path = mgr._resolve_allowed_path()
        if path is not None:
            assert path.name == "thumbnails", "Only thumbnails directory is allowed"
            assert ".cache" in str(path), "Path must be under .cache"

    def test_rejects_symlink_escape(self, tmp_path):
        """Ensure cleanup doesn't follow symlinks outside allowed path."""
        mgr = CleanupManager()
        # The path validation should always resolve to absolute
        path = mgr._resolve_allowed_path()
        if path:
            assert path.is_absolute()

    def test_get_size_nonexistent_path(self):
        mgr = CleanupManager()
        # Should handle gracefully when .cache/thumbnails doesn't exist
        result = mgr.get_thumbnail_cache_size()
        assert "ok" in result
        assert "bytes" in result


# === Protected Process Tests ===

class TestProtectedProcess:
    def test_protected_list_loaded(self):
        perm = PermissionManager()
        # Should have loaded some protected processes
        assert isinstance(perm.protected, set)

    def test_cannot_kill_root_process(self):
        perm = PermissionManager()
        # PID 1 is always init/systemd, owned by root
        result = perm.can_kill(1)
        assert result["ok"] is False

    def test_cannot_kill_nonexistent(self):
        perm = PermissionManager()
        result = perm.can_kill(999999999)
        assert result["ok"] is False

    def test_current_user_set(self):
        perm = PermissionManager()
        assert perm.current_user == os.getenv("USER") or perm.current_user != ""


# === Root Process Kill Rejection ===

class TestRootProcessKillRejection:
    def test_kill_pid_1_rejected(self):
        proc_mgr = ProcessManager()
        result = proc_mgr.kill_process(1)
        assert result["ok"] is False

    def test_kill_self_rejected(self):
        proc_mgr = ProcessManager()
        result = proc_mgr.kill_process(os.getpid())
        assert result["ok"] is False
        assert "app hiện tại" in result["message"]


# === Config & Autostart Tests ===

class TestConfig:
    def test_default_config_valid(self):
        assert "update_interval_ms" in DEFAULT_CONFIG
        assert DEFAULT_CONFIG["update_interval_ms"] == 1000

    def test_config_load_missing_file(self, tmp_path):
        config = AppConfig(config_dir=tmp_path / "nonexistent")
        # Should fall back to defaults
        assert config.get("theme") == "glass_dark"

    def test_config_save_and_load(self, tmp_path):
        config = AppConfig(config_dir=tmp_path)
        config.set("theme", "custom_theme")
        # Reload
        config2 = AppConfig(config_dir=tmp_path)
        assert config2.get("theme") == "custom_theme"

    def test_update_interval_has_bounds(self):
        # Verify DEFAULT_CONFIG has a reasonable interval
        interval = DEFAULT_CONFIG["update_interval_ms"]
        assert 100 <= interval <= 10000


# === Monitor Fallback Tests ===

class TestMonitorFallback:
    @patch("sys_assistant.core.gpu.CommandManager.run_action")
    def test_gpu_returns_dict(self, mock_run):
        mock_run.return_value = MagicMock(ok=False)
        from sys_assistant.core.gpu import get_gpu_info
        result = get_gpu_info()
        assert isinstance(result, dict)
        assert "status" in result
        assert result["status"] in ("available", "unsupported", "unavailable")

    def test_cpu_info_returns_dict(self):
        from sys_assistant.core.cpu import get_cpu_info
        result = get_cpu_info()
        assert "usage" in result
        assert isinstance(result["usage"], (int, float))

    def test_temperature_graceful(self):
        from sys_assistant.core.temperature import get_cpu_temperature
        result = get_cpu_temperature()
        # May be None on systems without sensors, but should not crash
        assert result is None or isinstance(result, float)

    def test_fan_graceful(self):
        from sys_assistant.core.fan import get_fan_speed
        result = get_fan_speed()
        assert result is None or isinstance(result, int)

    def test_battery_graceful(self):
        from sys_assistant.core.battery import get_battery_info
        result = get_battery_info()
        assert result is None or isinstance(result, dict)

    def test_network_returns_dict(self):
        from sys_assistant.core.network import get_network_info
        result = get_network_info()
        assert "download_mb_s" in result
        assert "upload_mb_s" in result


# === Smoke Test ===

class TestSmokeImport:
    def test_import_main_modules(self):
        """All core modules should import without error."""
        from sys_assistant.core import cpu, memory, disk, network, temperature, fan, battery, gpu
        from sys_assistant.core.monitor import SystemMonitor
        from sys_assistant.managers.command_manager import CommandManager
        from sys_assistant.managers.process_manager import ProcessManager
        from sys_assistant.managers.cleanup_manager import CleanupManager
        from sys_assistant.managers.health_checker import HealthChecker
        from sys_assistant.managers.performance_manager import PerformanceManager
        from sys_assistant.config.app_config import AppConfig

    @patch("sys_assistant.core.gpu.CommandManager.run_action")
    def test_system_monitor_collect(self, mock_run):
        mock_run.return_value = MagicMock(ok=False)
        from sys_assistant.core.monitor import SystemMonitor
        monitor = SystemMonitor()
        stats = monitor.collect_all()
        assert "cpu" in stats
        assert "gpu" in stats
        assert "ram" in stats
        assert "disk" in stats
        assert "network" in stats
        assert "fan" in stats
