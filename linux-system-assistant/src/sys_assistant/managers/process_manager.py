from __future__ import annotations

import os
import signal
from pathlib import Path
from typing import Any

import psutil

from sys_assistant.managers.command_manager import CommandManager
from sys_assistant.managers.permission_manager import PermissionManager
from sys_assistant.services.logger_service import LoggerService


class ProcessManager:
    def __init__(
        self,
        permission_manager: PermissionManager | None = None,
        logger: LoggerService | None = None,
        command_manager: CommandManager | None = None,
    ) -> None:
        self.permission = permission_manager or PermissionManager()
        self.logger = logger or LoggerService()
        self.command_manager = command_manager or CommandManager()
        self._logical_cpu_count = max(psutil.cpu_count(logical=True) or 1, 1)
        self._pending_kills: dict[int, float] = {}
        self._desktop_icon_cache: dict[str, tuple[str, str | None]] | None = None
        self._icon_path_cache: dict[str, str | None] = {}

    def get_top_processes(self, limit: int = 15, sort_by: str = "cpu") -> list[dict[str, Any]]:
        processes = self._get_processes_from_ps()
        if not processes:
            processes = self._get_processes_from_psutil()

        if sort_by == "memory":
            processes.sort(key=lambda item: (item["memory_mb"], item["cpu"]), reverse=True)
        else:
            processes.sort(key=lambda item: (item["cpu"], item["memory_mb"]), reverse=True)
        return processes[:limit]

    def _get_processes_from_ps(self) -> list[dict[str, Any]]:
        result = self.command_manager.run_action("process_snapshot")
        if not result.ok or not result.stdout.strip():
            return []

        current_uid = os.getuid()
        current_pid = os.getpid()
        total_memory = max(psutil.virtual_memory().total, 1)
        processes: list[dict[str, Any]] = []
        for line in result.stdout.splitlines():
            parts = line.split(None, 6)
            if len(parts) < 5:
                continue

            try:
                if len(parts) >= 7:
                    pid = int(parts[0])
                    uid = int(parts[1])
                    username = parts[2]
                    cpu = float(parts[3])
                    mem_percent = float(parts[4])
                    rss_kb = int(parts[5])
                    name = parts[6]
                else:
                    pid = int(parts[0])
                    uid = int(parts[1])
                    username = str(uid)
                    cpu = float(parts[2])
                    rss_kb = int(parts[3])
                    name = parts[4]
                    mem_percent = (rss_kb * 1024 / total_memory) * 100
            except ValueError:
                continue
            is_protected = pid == 1 or self._is_protected_name(name) or self.permission.is_protected(name)

            display_name, icon_name, icon_path = self._resolve_process_icon(name)
            normalized_cpu = self._normalize_process_cpu(cpu)
            killable = uid == current_uid and pid != current_pid and not is_protected
            processes.append(
                {
                    "pid": pid,
                    "name": name,
                    "displayName": display_name,
                    "iconName": icon_name,
                    "iconPath": icon_path or "",
                    "fallbackLetter": self._fallback_letter(display_name or name),
                    "cpu": normalized_cpu,
                    "cpuCorePercent": round(cpu, 1),
                    "memory_mb": round(rss_kb / 1024, 1),
                    "memory_percent": round(max(mem_percent, 0.0), 1),
                    "username": username,
                    "protected": is_protected,
                    "killable": killable,
                }
            )
        return processes

    def _get_processes_from_psutil(self) -> list[dict[str, Any]]:
        processes: list[dict[str, Any]] = []
        current_pid = os.getpid()
        current_user = self.permission.current_user

        for proc in psutil.process_iter(["pid", "name", "username", "memory_info", "memory_percent"]):
            try:
                info = proc.info
                is_protected = info["pid"] == 1 or self.permission.is_protected(proc)
                cpu = proc.cpu_percent(interval=0.0)
                normalized_cpu = self._normalize_process_cpu(cpu)
                mem_mb = round(info["memory_info"].rss / (1024**2), 1)
                mem_percent = round(float(info.get("memory_percent") or 0.0), 1)
                name = str(info["name"] or "Unknown")
                display_name, icon_name, icon_path = self._resolve_process_icon(name)
                username = str(info.get("username") or "")
                killable = username == current_user and info["pid"] != current_pid and not is_protected
                processes.append(
                    {
                        "pid": info["pid"],
                        "name": name,
                        "displayName": display_name,
                        "iconName": icon_name,
                        "iconPath": icon_path or "",
                        "fallbackLetter": self._fallback_letter(display_name or name),
                        "cpu": normalized_cpu,
                        "cpuCorePercent": round(cpu, 1),
                        "memory_mb": mem_mb,
                        "memory_percent": mem_percent,
                        "username": username,
                        "protected": is_protected,
                        "killable": killable,
                    }
                )
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue

        return processes

    def _normalize_process_cpu(self, cpu_percent: float) -> float:
        """Convert per-core Linux process CPU percent to whole-machine percent."""
        return round(max(cpu_percent, 0.0) / self._logical_cpu_count, 1)

    def kill_process(self, pid: int, force: bool = False) -> dict[str, Any]:
        import time
        check = self.permission.can_kill(pid)
        if not check["ok"]:
            return check

        if pid == os.getpid():
            return {"ok": False, "message": "Không thể kill chính app hiện tại."}

        # Enforce SIGTERM before SIGKILL
        now = time.time()
        if force:
            last_sigterm = self._pending_kills.get(pid, 0.0)
            if now - last_sigterm > 30.0:
                return {"ok": False, "message": "Phải gửi SIGTERM trước khi có thể Force Kill."}
            self._pending_kills.pop(pid, None)
        else:
            self._pending_kills[pid] = now

        try:
            process = psutil.Process(pid)
            sig = signal.SIGKILL if force else signal.SIGTERM
            process.send_signal(sig)
            action = "force_kill" if force else "kill"
            self.logger.log_action(action, f"pid={pid} name={check.get('name', '?')}")
            return {
                "ok": True,
                "message": f"Đã gửi {'SIGKILL' if force else 'SIGTERM'} tới PID {pid}.",
                "force": force,
            }
        except psutil.NoSuchProcess:
            return {"ok": False, "message": "Process không còn tồn tại."}
        except psutil.AccessDenied:
            return {"ok": False, "message": "Không có quyền kill process này."}

    def is_process_alive(self, pid: int) -> bool:
        return psutil.pid_exists(pid)

    def _resolve_process_icon(self, process_name: str) -> tuple[str, str, str | None]:
        normalized = self._normalize_name(process_name)
        mapped = {
            "chrome": "google-chrome",
            "google-chrome": "google-chrome",
            "chromium": "chromium",
            "firefox": "firefox",
            "code": "visual-studio-code",
            "code-insiders": "visual-studio-code-insiders",
            "discord": "discord",
            "steam": "steam",
            "spotify": "spotify",
            "telegram": "telegram",
            "slack": "slack",
        }
        lookup_names = [normalized]
        if normalized in mapped:
            lookup_names.insert(0, mapped[normalized])

        desktop_icons = self._load_desktop_icons()
        for key in lookup_names:
            if key in desktop_icons:
                display_name, icon_name = desktop_icons[key]
                return display_name, icon_name or key, self._find_icon_path(icon_name or key)

        icon_name = lookup_names[0]
        return process_name, icon_name, self._find_icon_path(icon_name)

    def _is_protected_name(self, process_name: str) -> bool:
        name = self._normalize_name(process_name)
        return name in self.permission.protected or any(
            protected in name for protected in self.permission.protected if len(protected) > 3
        )

    def _load_desktop_icons(self) -> dict[str, tuple[str, str | None]]:
        if self._desktop_icon_cache is not None:
            return self._desktop_icon_cache

        entries: dict[str, tuple[str, str | None]] = {}
        app_dirs = [
            Path("/usr/share/applications"),
            Path("/usr/local/share/applications"),
            Path.home() / ".local" / "share" / "applications",
        ]
        for app_dir in app_dirs:
            if not app_dir.exists():
                continue
            for desktop_file in app_dir.glob("*.desktop"):
                try:
                    data = desktop_file.read_text(encoding="utf-8", errors="replace")
                except OSError:
                    continue
                name = desktop_file.stem
                display_name = name
                icon_name: str | None = None
                exec_name: str | None = None
                for line in data.splitlines():
                    if line.startswith("Name=") and display_name == name:
                        display_name = line.split("=", 1)[1].strip() or name
                    elif line.startswith("Icon="):
                        icon_name = line.split("=", 1)[1].strip() or None
                    elif line.startswith("Exec="):
                        exec_value = line.split("=", 1)[1].strip().split(" ", 1)[0]
                        exec_name = Path(exec_value).name if exec_value else None

                keys = {self._normalize_name(name)}
                if exec_name:
                    keys.add(self._normalize_name(exec_name))
                if display_name:
                    keys.add(self._normalize_name(display_name))
                for key in keys:
                    if key and key not in entries:
                        entries[key] = (display_name, icon_name)

        self._desktop_icon_cache = entries
        return entries

    def _find_icon_path(self, icon_name: str | None) -> str | None:
        if not icon_name:
            return None
        if icon_name in self._icon_path_cache:
            return self._icon_path_cache[icon_name]

        icon_path = Path(icon_name).expanduser()
        if icon_path.is_absolute() and icon_path.exists():
            resolved = str(icon_path)
            self._icon_path_cache[icon_name] = resolved
            return resolved

        icon_roots = [
            Path.home() / ".local" / "share" / "icons",
            Path("/usr/share/icons/hicolor"),
            Path("/usr/share/icons"),
            Path("/usr/share/pixmaps"),
        ]
        
        subdirs = [
            "",
            "48x48/apps",
            "64x64/apps",
            "128x128/apps",
            "scalable/apps",
            "256x256/apps",
            "32x32/apps",
            "16x16/apps",
            "apps"
        ]
        
        exts = (".png", ".svg", ".xpm")
        
        for root in icon_roots:
            if not root.exists():
                continue
            for subdir in subdirs:
                base_dir = root / subdir if subdir else root
                if not base_dir.exists():
                    continue
                for ext in exts:
                    direct = base_dir / f"{icon_name}{ext}"
                    if direct.exists():
                        resolved = str(direct)
                        self._icon_path_cache[icon_name] = resolved
                        return resolved

        self._icon_path_cache[icon_name] = None
        return None

    @staticmethod
    def _normalize_name(value: str) -> str:
        value = Path(value).name.lower().strip()
        for suffix in (".desktop", ".bin", ".exe"):
            if value.endswith(suffix):
                value = value[: -len(suffix)]
        return value

    @staticmethod
    def _fallback_letter(value: str) -> str:
        for char in value.strip():
            if char.isalnum():
                return char.upper()
        return "?"
