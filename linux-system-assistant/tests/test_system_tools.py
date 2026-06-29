"""Tests for the new system_tools module."""
from __future__ import annotations
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

from sys_assistant.system_tools.status import (
    OK, WARNING, ERROR, UNKNOWN, TIMEOUT, merge_status, evaluate_threshold, label,
)
from sys_assistant.system_tools.size_utils import human_size, dir_size_safe
from sys_assistant.system_tools.safe_command_runner import SafeCommandRunner, CommandSpec


class TestStatus:
    def test_merge_ok(self):
        assert merge_status(OK, OK) == OK

    def test_merge_warning(self):
        assert merge_status(OK, WARNING) == WARNING

    def test_merge_error(self):
        assert merge_status(WARNING, ERROR) == ERROR

    def test_merge_unknown(self):
        assert merge_status(OK, UNKNOWN) == UNKNOWN

    def test_threshold_ok(self):
        assert evaluate_threshold(50, 80, (80, 90), 90) == OK

    def test_threshold_warning(self):
        assert evaluate_threshold(85, 80, (80, 90), 90) == WARNING

    def test_threshold_error(self):
        assert evaluate_threshold(95, 80, (80, 90), 90) == ERROR

    def test_labels(self):
        assert label(OK) == "Tốt"
        assert label(ERROR) == "Lỗi"
        assert label(UNKNOWN) == "Không khả dụng"


class TestSizeUtils:
    def test_human_size_bytes(self):
        assert human_size(0) == "0 B"
        assert human_size(500) == "500 B"

    def test_human_size_kb(self):
        assert human_size(1024) == "1.0 KB"

    def test_human_size_mb(self):
        assert human_size(1048576) == "1.0 MB"

    def test_human_size_gb(self):
        assert human_size(1073741824) == "1.0 GB"

    def test_dir_size_nonexistent(self):
        p = Path("/nonexistent_test_dir_xyz")
        total, count = dir_size_safe(p)
        assert total == 0
        assert count == 0


class TestSafeCommandRunner:
    def test_forbidden_command_rejected(self):
        runner = SafeCommandRunner()
        spec = CommandSpec(id="test_rm", title="test", command=["rm", "-rf", "/"])
        result = runner.run(spec)
        assert result.status == ERROR
        assert "cấm" in result.error_message

    def test_missing_optional_command(self):
        runner = SafeCommandRunner()
        spec = CommandSpec(id="test_missing", title="test",
                          command=["nonexistent_cmd_xyz"],
                          run_if_available="nonexistent_cmd_xyz")
        result = runner.run(spec)
        assert result.status == UNKNOWN

    def test_valid_command(self):
        runner = SafeCommandRunner()
        spec = CommandSpec(id="test_echo", title="test", command=["echo", "hello"])
        result = runner.run(spec)
        assert result.status == OK
        assert "hello" in result.stdout


class TestSystemChecker:
    def test_run_system_check_returns_report(self):
        from sys_assistant.system_tools.system_check import SystemChecker
        checker = SystemChecker()
        report = checker.run_system_check()
        assert "overall_status" in report
        assert "overall_label" in report
        assert "checked_at" in report
        assert "ui_summary" in report
        assert "sections" in report
        assert len(report["ui_summary"]) == 8
        assert len(report["sections"]) == 8

    def test_ui_summary_has_all_sections(self):
        from sys_assistant.system_tools.system_check import SystemChecker
        checker = SystemChecker()
        report = checker.run_system_check()
        ids = {s["id"] for s in report["ui_summary"]}
        expected = {"cpu", "gpu", "disk", "ram", "service", "log", "network", "temperature"}
        assert ids == expected


class TestCleanupScanner:
    def test_scan_returns_targets(self):
        from sys_assistant.system_tools.cleanup import CleanupScanner
        scanner = CleanupScanner()
        result = scanner.scan()
        assert "targets" in result
        assert "total_cleanable_bytes" in result
        assert "total_cleanable_label" in result
        assert len(result["targets"]) == 6  # 6 whitelist targets

    def test_scan_target_ids(self):
        from sys_assistant.system_tools.cleanup import CleanupScanner
        scanner = CleanupScanner()
        result = scanner.scan()
        ids = {t["id"] for t in result["targets"]}
        expected = {"thumbnail_cache", "fontconfig_cache", "gstreamer_cache", "pip_cache", "npm_cache", "trash"}
        assert ids == expected

    def test_cleanup_invalid_id_rejected(self):
        from sys_assistant.system_tools.cleanup import CleanupScanner
        scanner = CleanupScanner()
        result = scanner.run_cleanup(["invalid_id_xyz"])
        assert len(result["errors"]) > 0

    def test_cleanup_trash_needs_confirm(self):
        from sys_assistant.system_tools.cleanup import CleanupScanner
        scanner = CleanupScanner()
        result = scanner.run_cleanup(["trash"], confirm_trash=False)
        # Should be skipped since confirm_trash is False
        skipped = [t for t in result["cleaned_targets"] if t["status"] == "skipped"]
        assert len(skipped) > 0


class TestHardwareInfo:
    def test_get_hardware_info_returns_report(self):
        from sys_assistant.system_tools.hardware_info import HardwareInfoCollector
        collector = HardwareInfoCollector()
        result = collector.get_hardware_info()
        assert "status" in result
        assert "hardware" in result
        hw = result["hardware"]
        for key in ["cpu", "gpu", "ram", "swap", "disk", "network", "battery"]:
            assert key in hw
            assert "status" in hw[key]
            assert "ui_text" in hw[key]

    def test_hardware_no_crash_without_nvidia(self):
        from sys_assistant.system_tools.hardware_info import HardwareInfoCollector
        collector = HardwareInfoCollector()
        result = collector.get_hardware_info()
        # Should not crash, GPU should be unknown or have info
        assert result["hardware"]["gpu"]["status"] in (OK, WARNING, UNKNOWN, ERROR)

    def test_hardware_no_crash_without_battery(self):
        from sys_assistant.system_tools.hardware_info import HardwareInfoCollector
        collector = HardwareInfoCollector()
        result = collector.get_hardware_info()
        bat = result["hardware"]["battery"]
        assert bat["status"] in (OK, WARNING, UNKNOWN, ERROR)
