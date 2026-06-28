from __future__ import annotations

from pathlib import Path

DESKTOP_TEMPLATE = """[Desktop Entry]
Type=Application
Name=Linux System Assistant
Comment=Floating system monitor and control widget
Exec={exec_path}
Terminal=false
Categories=Utility;System;
StartupNotify=false
X-KDE-Autostart-enabled=true
"""


class AutostartService:
    def __init__(self, exec_path: str | None = None) -> None:
        self.autostart_dir = Path.home() / ".config" / "autostart"
        self.desktop_path = self.autostart_dir / "linux-system-assistant.desktop"
        self.exec_path = exec_path or self._default_exec_path()

    def enable(self) -> dict:
        self.autostart_dir.mkdir(parents=True, exist_ok=True)
        content = DESKTOP_TEMPLATE.format(exec_path=self.exec_path)
        self.desktop_path.write_text(content, encoding="utf-8")
        return {"ok": True, "message": "Autostart đã bật.", "path": str(self.desktop_path)}

    def disable(self) -> dict:
        if self.desktop_path.exists():
            self.desktop_path.unlink()
        return {"ok": True, "message": "Autostart đã tắt."}

    def is_enabled(self) -> bool:
        return self.desktop_path.exists()

    @staticmethod
    def _default_exec_path() -> str:
        root = Path(__file__).resolve().parents[3]
        run_script = root / "run.sh"
        if run_script.exists():
            return str(run_script)
        return "python3 -m sys_assistant.main"
