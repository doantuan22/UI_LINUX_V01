from __future__ import annotations

import os

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
        assert "memory_mb" in item


def test_protected_systemd():
    permission = PermissionManager()
    assert "systemd" in permission.protected
