from __future__ import annotations

import json
from copy import deepcopy
from pathlib import Path
from typing import Any

DEFAULT_CONFIG: dict[str, Any] = {
    "autostart": False,
    "theme": "glass_dark",
    "update_interval_ms": 1000,
    "show_temperature": True,
    "show_network_speed": True,
    "safe_mode_process_kill": True,
    "start_minimized": False,
    "notifications_enabled": True,
    "auto_hide": False,
    "floating_icon": {
        "x": 100,
        "y": 100,
    },
}


class AppConfig:
    def __init__(self, config_dir: Path | None = None) -> None:
        self.config_dir = config_dir or Path.home() / ".config" / "linux-system-assistant"
        self.config_path = self.config_dir / "config.json"
        self._data = deepcopy(DEFAULT_CONFIG)
        self.load()

    def load(self) -> dict[str, Any]:
        if self.config_path.exists():
            try:
                loaded = json.loads(self.config_path.read_text(encoding="utf-8"))
                if isinstance(loaded, dict):
                    self._merge(loaded)
            except (OSError, json.JSONDecodeError):
                pass
        return self._data

    def save(self) -> None:
        self.config_dir.mkdir(parents=True, exist_ok=True)
        self.config_path.write_text(
            json.dumps(self._data, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    def get(self, key: str, default: Any = None) -> Any:
        return self._data.get(key, default)

    def set(self, key: str, value: Any) -> None:
        self._data[key] = value
        self.save()

    def update(self, updates: dict[str, Any]) -> None:
        self._data.update(updates)
        self.save()

    def as_dict(self) -> dict[str, Any]:
        return deepcopy(self._data)

    def _merge(self, loaded: dict[str, Any]) -> None:
        for key, value in loaded.items():
            if key == "floating_icon" and isinstance(value, dict):
                current = self._data.setdefault("floating_icon", {})
                if isinstance(current, dict):
                    current.update(value)
            else:
                self._data[key] = value
