from __future__ import annotations

import logging
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


class RecentLogHandler(logging.Handler):
    def __init__(self, records: list[dict[str, Any]], limit: int = 80) -> None:
        super().__init__(level=logging.WARNING)
        self.records = records
        self.limit = limit

    def emit(self, record: logging.LogRecord) -> None:
        message = self.format(record)
        self.records.append(
            {
                "level": record.levelname.lower(),
                "title": record.levelname,
                "message": message,
                "time": datetime.fromtimestamp(record.created, timezone.utc).strftime("%H:%M:%S"),
            }
        )
        del self.records[:-self.limit]


class LoggerService:
    _recent_records: list[dict[str, Any]] = []

    def __init__(self, log_path: Path | None = None) -> None:
        self.log_path = log_path or (
            Path.home() / ".local" / "state" / "linux-system-assistant" / "app.log"
        )
        self._logger = logging.getLogger("linux-system-assistant")
        if not self._logger.handlers:
            try:
                self.log_path.parent.mkdir(parents=True, exist_ok=True)
                handler = logging.FileHandler(self.log_path, encoding="utf-8")
            except (OSError, PermissionError):
                try:
                    self.log_path = Path("/tmp/linux-system-assistant.log")
                    handler = logging.FileHandler(self.log_path, encoding="utf-8")
                except (OSError, PermissionError):
                    handler = logging.StreamHandler()

            handler.setFormatter(
                logging.Formatter("%(asctime)s [%(levelname)s] %(message)s")
            )
            self._logger.addHandler(handler)
            memory_handler = RecentLogHandler(self._recent_records)
            memory_handler.setFormatter(logging.Formatter("%(message)s"))
            self._logger.addHandler(memory_handler)
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

    def recent_errors(self) -> list[dict[str, Any]]:
        return list(self._recent_records)

    def clear_recent_errors(self) -> None:
        self._recent_records.clear()
