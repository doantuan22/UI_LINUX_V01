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
        self._cached_profiles: list[str] | None = None
        self._cached_supported: bool | None = None

    def is_supported(self) -> bool:
        if self._cached_supported is not None:
            return self._cached_supported
            
        import shutil
        self._cached_supported = shutil.which("powerprofilesctl") is not None
        return self._cached_supported

    def get_current_profile(self) -> str:
        if not self.is_supported():
            return "unknown"
        result = self.commands.run_action("power_profile_get")
        if result.ok and result.stdout.strip():
            return result.stdout.strip()
        return "unknown"

    def list_profiles(self) -> list[str]:
        if self._cached_profiles is not None:
            return self._cached_profiles
            
        if not self.is_supported():
            self._cached_profiles = []
            return []
            
        result = self.commands.run_action("power_profile_list")
        if not result.ok:
            self._cached_profiles = []
            return []

        profiles: list[str] = []
        for line in result.stdout.splitlines():
            match = re.search(r"(\S+):\s*$", line.strip())
            if match:
                profiles.append(match.group(1))
        
        self._cached_profiles = profiles
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
            "current": "unknown", # Rely on bridge cache for current profile
            "available": profiles or list(PROFILE_ACTIONS.keys()),
        }
