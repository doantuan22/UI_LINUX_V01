from __future__ import annotations

import logging
from datetime import datetime, timezone
from pathlib import Path


class LoggerService:
    def __init__(self, log_path: Path | None = None) -> None:
        self.log_path = log_path or (
            Path.home() / ".local" / "state" / "linux-system-assistant" / "app.log"
        )
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        self._logger = logging.getLogger("linux-system-assistant")
        if not self._logger.handlers:
            handler = logging.FileHandler(self.log_path, encoding="utf-8")
            handler.setFormatter(
                logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
            )
            self._logger.addHandler(handler)
            self._logger.setLevel(logging.INFO)

    def info(self, message: str) -> None:
        self._logger.info(message)

    def warning(self, message: str) -> None:
        self._logger.warning(message)

    def error(self, message: str) -> None:
        self._logger.error(message)

    def log_action(self, action_key: str, detail: str = "") -> None:
        timestamp = datetime.now(timezone.utc).isoformat()
        self.info(f"ACTION {timestamp} key={action_key} detail={detail}")
