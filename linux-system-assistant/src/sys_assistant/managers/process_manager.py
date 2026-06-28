from __future__ import annotations

import os
import signal
from typing import Any

import psutil

from sys_assistant.managers.permission_manager import PermissionManager
from sys_assistant.services.logger_service import LoggerService


class ProcessManager:
    def __init__(
        self,
        permission_manager: PermissionManager | None = None,
        logger: LoggerService | None = None,
    ) -> None:
        self.permission = permission_manager or PermissionManager()
        self.logger = logger or LoggerService()
        self._pending_kills: dict[int, float] = {}

    def get_top_processes(self, limit: int = 15, sort_by: str = "memory") -> list[dict[str, Any]]:
        processes: list[dict[str, Any]] = []
        current_user = self.permission.current_user

        for proc in psutil.process_iter(["pid", "name", "username", "memory_info"]):
            try:
                info = proc.info
                if info["username"] != current_user:
                    continue

                is_protected = self.permission.is_protected(proc)
                cpu = proc.cpu_percent(interval=0.0)
                mem_mb = round(info["memory_info"].rss / (1024**2), 1)
                processes.append(
                    {
                        "pid": info["pid"],
                        "name": info["name"],
                        "cpu": round(cpu, 1),
                        "memory_mb": mem_mb,
                        "protected": is_protected,
                    }
                )
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue

        if sort_by == "cpu":
            processes.sort(key=lambda item: item["cpu"], reverse=True)
        else:
            processes.sort(key=lambda item: (item["memory_mb"], item["cpu"]), reverse=True)
        return processes[:limit]

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
