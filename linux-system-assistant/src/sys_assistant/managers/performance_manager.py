from __future__ import annotations

import re
from typing import Any

from sys_assistant.managers.command_manager import CommandManager
from sys_assistant.services.logger_service import LoggerService

PROFILE_ACTIONS = {
    "power-saver": "power_saver",
    "balanced": "balanced",
    "performance": "performance",
}


class PerformanceManager:
    def __init__(
        self,
        command_manager: CommandManager | None = None,
        logger: LoggerService | None = None,
    ) -> None:
        self.commands = command_manager or CommandManager()
        self.logger = logger or LoggerService()

    def is_supported(self) -> bool:
        import shutil

        return shutil.which("powerprofilesctl") is not None

    def get_current_profile(self) -> str:
        result = self.commands.run_action("power_profile_get")
        if result.ok and result.stdout.strip():
            return result.stdout.strip()
        return "unknown"

    def list_profiles(self) -> list[str]:
        result = self.commands.run_action("power_profile_list")
        if not result.ok:
            return []

        profiles: list[str] = []
        for line in result.stdout.splitlines():
            match = re.search(r"(\S+):\s*$", line.strip())
            if match:
                profiles.append(match.group(1))
        return profiles

    def set_profile(self, profile: str) -> dict[str, Any]:
        action_key = PROFILE_ACTIONS.get(profile)
        if not action_key:
            return {"ok": False, "message": f"Profile không hợp lệ: {profile}"}

        available = self.list_profiles()
        if available and profile not in available:
            return {"ok": False, "message": f"Profile '{profile}' không khả dụng trên hệ thống."}

        result = self.commands.run_action(action_key)
        if result.ok:
            self.logger.log_action("set_power_profile", profile)
        return {
            "ok": result.ok,
            "message": result.message if result.ok else result.message,
            "profile": profile,
        }

    def get_status(self) -> dict[str, Any]:
        profiles = self.list_profiles()
        return {
            "supported": bool(profiles) or self.is_supported(),
            "current": self.get_current_profile(),
            "available": profiles or list(PROFILE_ACTIONS.keys()),
        }
