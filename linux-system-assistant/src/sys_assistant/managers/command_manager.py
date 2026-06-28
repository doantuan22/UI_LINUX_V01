from __future__ import annotations

import subprocess
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml


@dataclass
class CommandResult:
    ok: bool
    action_key: str
    stdout: str
    stderr: str
    exit_code: int
    message: str


class CommandManager:
    """Single gateway for whitelisted system commands."""

    def __init__(self, config_path: Path | None = None) -> None:
        if config_path is None:
            config_path = Path(__file__).resolve().parent.parent / "config" / "safe_commands.yaml"
        self.commands = self._load_commands(config_path)

    def _load_commands(self, config_path: Path) -> dict[str, dict[str, Any]]:
        if not config_path.exists():
            return {}
        with config_path.open(encoding="utf-8") as handle:
            data = yaml.safe_load(handle) or {}
        return {key: value for key, value in data.items() if isinstance(value, dict)}

    def run_action(self, action_key: str) -> CommandResult:
        if action_key not in self.commands:
            return CommandResult(
                ok=False,
                action_key=action_key,
                stdout="",
                stderr="",
                exit_code=-1,
                message="Action không nằm trong whitelist.",
            )

        spec = self.commands[action_key]
        cmd = spec["command"]
        timeout_sec = spec.get("timeout_sec", 10)

        try:
            completed = subprocess.run(
                cmd,
                shell=False,
                capture_output=True,
                text=True,
                timeout=timeout_sec,
                check=False,
            )
            return CommandResult(
                ok=completed.returncode == 0,
                action_key=action_key,
                stdout=completed.stdout,
                stderr=completed.stderr,
                exit_code=completed.returncode,
                message="OK" if completed.returncode == 0 else "Command chạy không thành công.",
            )
        except FileNotFoundError:
            return CommandResult(
                ok=False,
                action_key=action_key,
                stdout="",
                stderr="",
                exit_code=-1,
                message=f"Không tìm thấy command: {cmd[0]}",
            )
        except subprocess.TimeoutExpired:
            return CommandResult(
                ok=False,
                action_key=action_key,
                stdout="",
                stderr="",
                exit_code=-1,
                message="Command bị timeout.",
            )

    def is_available(self, action_key: str) -> bool:
        return action_key in self.commands
