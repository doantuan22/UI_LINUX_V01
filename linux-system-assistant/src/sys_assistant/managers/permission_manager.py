from __future__ import annotations

import getpass
from pathlib import Path
from typing import Any

import psutil
import yaml


class PermissionManager:
    def __init__(self, config_path: Path | None = None) -> None:
        if config_path is None:
            config_path = (
                Path(__file__).resolve().parent.parent / "config" / "protected_processes.yaml"
            )
        self.protected = self._load_protected(config_path)
        self.current_user = getpass.getuser()

    def _load_protected(self, config_path: Path) -> set[str]:
        if not config_path.exists():
            return set()
        with config_path.open(encoding="utf-8") as handle:
            data = yaml.safe_load(handle) or {}
        items = data.get("protected", [])
        return {str(item).lower() for item in items}

    def is_protected(self, process: psutil.Process) -> bool:
        try:
            name = process.name().lower()
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            return True
        return name in self.protected or any(
            protected in name for protected in self.protected if len(protected) > 3
        )

    def can_kill(self, pid: int) -> dict[str, Any]:
        try:
            process = psutil.Process(pid)
        except psutil.NoSuchProcess:
            return {"ok": False, "message": "Process không còn tồn tại."}

        try:
            owner = process.username()
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            return {"ok": False, "message": "Không thể xác định owner của process."}

        if owner == "root":
            return {"ok": False, "message": "Nghiêm cấm can thiệp tiến trình của root."}

        if owner != self.current_user:
            return {"ok": False, "message": "Chỉ được kill process của user hiện tại."}

        if self.is_protected(process):
            return {"ok": False, "message": "Process này nằm trong danh sách protected."}

        return {"ok": True, "message": "OK", "name": process.name()}
