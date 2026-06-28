from __future__ import annotations

import shutil
from pathlib import Path
from typing import Any

from sys_assistant.services.logger_service import LoggerService

THUMBNAIL_CACHE = Path.home() / ".cache" / "thumbnails"


class CleanupManager:
    def __init__(self, logger: LoggerService | None = None) -> None:
        self.logger = logger or LoggerService()

    def get_thumbnail_cache_size(self) -> dict[str, Any]:
        path = self._resolve_allowed_path()
        if path is None:
            return {"ok": False, "bytes": 0, "human": "0 B", "message": "Path không hợp lệ."}

        if not path.exists():
            return {"ok": True, "bytes": 0, "human": "0 B", "path": str(path)}

        total = sum(f.stat().st_size for f in path.rglob("*") if f.is_file())
        return {
            "ok": True,
            "bytes": total,
            "human": self._human_size(total),
            "path": str(path),
        }

    def clean_thumbnail_cache(self) -> dict[str, Any]:
        path = self._resolve_allowed_path()
        if path is None:
            return {"ok": False, "message": "Path không hợp lệ."}

        if not path.exists():
            return {"ok": True, "message": "Không có thumbnail cache để xóa.", "freed_bytes": 0}

        size_info = self.get_thumbnail_cache_size()
        freed = size_info.get("bytes", 0)

        try:
            shutil.rmtree(path)
            path.mkdir(parents=True, exist_ok=True)
            self.logger.log_action("clean_thumbnail_cache", f"freed={freed}")
            return {
                "ok": True,
                "message": f"Đã xóa thumbnail cache ({size_info.get('human', '0 B')}).",
                "freed_bytes": freed,
            }
        except OSError as exc:
            return {"ok": False, "message": f"Không thể xóa cache: {exc}"}

    def _resolve_allowed_path(self) -> Path | None:
        home = Path.home().resolve()
        target = THUMBNAIL_CACHE.resolve()
        try:
            target.relative_to(home)
        except ValueError:
            return None
        if target.name != "thumbnails":
            return None
        return target

    @staticmethod
    def _human_size(num_bytes: int) -> str:
        units = ["B", "KB", "MB", "GB"]
        size = float(num_bytes)
        for unit in units:
            if size < 1024 or unit == units[-1]:
                return f"{size:.1f} {unit}"
            size /= 1024
        return f"{num_bytes} B"
