from __future__ import annotations

import os
from unittest.mock import MagicMock, patch

from sys_assistant.managers.command_manager import CommandResult
from sys_assistant.managers.permission_manager import PermissionManager
from sys_assistant.managers.process_manager import ProcessManager


def test_cannot_kill_self():
    manager = ProcessManager()
    result = manager.kill_process(os.getpid())
    assert result["ok"] is False
    assert "app" in result["message"].lower() or "kill" in result["message"].lower()


def test_get_top_processes_returns_list():
    manager = ProcessManager()
    processes = manager.get_top_processes(limit=5)
    assert isinstance(processes, list)
    if processes:
        item = processes[0]
        assert "pid" in item
        assert "name" in item
        assert "cpu" in item
        assert "cpuCorePercent" in item
        assert "memory_mb" in item


def test_protected_systemd():
    permission = PermissionManager()
    assert "systemd" in permission.protected


def test_process_snapshot_uses_ps_cpu_and_rss():
    command_manager = MagicMock()
    command_manager.run_action.return_value = CommandResult(
        ok=True,
        action_key="process_snapshot",
        stdout=f"{os.getpid()} {os.getuid()} 12.0 204800 python\n999999 {os.getuid()} 99.9 1 gone\n",
        stderr="",
        exit_code=0,
        message="OK",
    )

    with patch("sys_assistant.managers.process_manager.psutil.cpu_count", return_value=10):
        manager = ProcessManager(command_manager=command_manager)
    processes = manager.get_top_processes(limit=5)

    current = next(item for item in processes if item["pid"] == os.getpid())
    assert current["cpu"] == 1.2
    assert current["cpuCorePercent"] == 12.0
    assert current["memory_mb"] == 200.0
    command_manager.run_action.assert_called_once_with("process_snapshot")


def test_process_snapshot_falls_back_to_psutil():
    command_manager = MagicMock()
    command_manager.run_action.return_value = CommandResult(
        ok=False,
        action_key="process_snapshot",
        stdout="",
        stderr="",
        exit_code=1,
        message="failed",
    )

    manager = ProcessManager(command_manager=command_manager)

    with patch.object(manager, "_get_processes_from_psutil", return_value=[
        {
            "pid": os.getpid(),
            "name": "python",
            "displayName": "python",
            "iconName": "python",
            "iconPath": "",
            "fallbackLetter": "P",
            "cpu": 1.0,
            "cpuCorePercent": 10.0,
            "memory_mb": 10.0,
            "protected": False,
        }
    ]):
        processes = manager.get_top_processes(limit=5)

    assert processes[0]["pid"] == os.getpid()
    assert processes[0]["cpu"] == 1.0
