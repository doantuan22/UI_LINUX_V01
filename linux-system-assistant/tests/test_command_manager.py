from __future__ import annotations

from sys_assistant.managers.command_manager import CommandManager


from unittest.mock import patch

def test_rejects_unknown_action():
    manager = CommandManager()
    result = manager.run_action("rm_rf_everything")
    assert result.ok is False
    assert "whitelist" in result.message.lower()

@patch("subprocess.run")
def test_check_disk_action(mock_run):
    mock_run.return_value.returncode = 0
    mock_run.return_value.stdout = "Filesystem      Size  Used Avail Use% Mounted on\n/dev/sda1        50G   10G   40G  20% /\n"
    mock_run.return_value.stderr = ""
    
    manager = CommandManager()
    result = manager.run_action("check_disk")
    assert result.action_key == "check_disk"
    assert result.ok is True
    assert isinstance(result.message, str)

def test_commands_loaded():
    manager = CommandManager()
    assert "balanced" in manager.commands
    assert manager.commands["balanced"]["command"] == ["powerprofilesctl", "set", "balanced"]
