from __future__ import annotations

from PySide6.QtWidgets import QSystemTrayIcon

from sys_assistant.services.logger_service import LoggerService


class NotificationService:
    def __init__(self, logger: LoggerService | None = None) -> None:
        self.logger = logger or LoggerService()
        self.enabled = True
        self._cooldowns: dict[str, float] = {}
        self._cooldown_sec = 60.0
        self._tray: QSystemTrayIcon | None = None

    def attach_tray(self, tray: QSystemTrayIcon) -> None:
        self._tray = tray

    def set_enabled(self, enabled: bool) -> None:
        self.enabled = enabled

    def notify(self, title: str, message: str, key: str = "general") -> None:
        if not self.enabled or self._tray is None:
            return

        import time

        now = time.time()
        last = self._cooldowns.get(key, 0)
        if now - last < self._cooldown_sec:
            return

        self._cooldowns[key] = now
        self._tray.showMessage(title, message, QSystemTrayIcon.MessageIcon.Information, 4000)
        self.logger.info(f"NOTIFY {title}: {message}")
