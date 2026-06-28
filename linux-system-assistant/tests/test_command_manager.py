from __future__ import annotations

from sys_assistant.managers.command_manager import CommandManager


def test_rejects_unknown_action():
    manager = CommandManager()
    result = manager.run_action("rm_rf_everything")
    assert result.ok is False
    assert "whitelist" in result.message.lower()


def test_check_disk_action():
    manager = CommandManager()
    result = manager.run_action("check_disk")
    assert result.action_key == "check_disk"
    # May fail in minimal CI without df, but should not crash
    assert isinstance(result.message, str)


def test_commands_loaded():
    manager = CommandManager()
    assert "balanced" in manager.commands
    assert manager.commands["balanced"]["command"] == ["powerprofilesctl", "set", "balanced"]
