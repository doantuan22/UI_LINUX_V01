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

    def get_top_processes(self, limit: int = 15) -> list[dict[str, Any]]:
        processes: list[dict[str, Any]] = []
        current_user = self.permission.current_user

        for proc in psutil.process_iter(["pid", "name", "username", "memory_info"]):
            try:
                info = proc.info
                if info["username"] != current_user:
                    continue
                if self.permission.is_protected(proc):
                    continue

                cpu = proc.cpu_percent(interval=0.0)
                mem_mb = round(info["memory_info"].rss / (1024**2), 1)
                processes.append(
                    {
                        "pid": info["pid"],
                        "name": info["name"],
                        "cpu": round(cpu, 1),
                        "memory_mb": mem_mb,
                        "protected": False,
                    }
                )
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue

        processes.sort(key=lambda item: (item["memory_mb"], item["cpu"]), reverse=True)
        return processes[:limit]

    def kill_process(self, pid: int, force: bool = False) -> dict[str, Any]:
        check = self.permission.can_kill(pid)
        if not check["ok"]:
            return check

        if pid == os.getpid():
            return {"ok": False, "message": "Không thể kill chính app hiện tại."}

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
