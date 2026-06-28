from __future__ import annotations

from typing import Any

from sys_assistant.managers.command_manager import CommandManager


class HealthChecker:
    CHECKS = [
        ("check_disk", "Disk usage"),
        ("check_failed_services", "Failed services"),
        ("check_critical_logs", "Critical logs"),
        ("check_hardware_gpu", "Hardware GPU"),
        ("check_block_devices", "Block devices"),
        ("check_sensors", "Sensors"),
    ]

    def __init__(self, command_manager: CommandManager | None = None) -> None:
        self.commands = command_manager or CommandManager()

    def run_system_check(self) -> dict[str, Any]:
        items: list[dict[str, Any]] = []
        warning_count = 0

        for action_key, name in self.CHECKS:
            result = self.commands.run_action(action_key)
            status = "ok" if result.ok else "warning"
            if not result.ok:
                warning_count += 1

            detail = result.message
            if result.ok and result.stdout.strip():
                first_line = result.stdout.strip().splitlines()[0]
                detail = first_line[:120]

            if action_key == "check_failed_services" and result.ok:
                failed_lines = [
                    line
                    for line in result.stdout.splitlines()
                    if line.strip() and not line.startswith("0 loaded")
                ]
                if len(failed_lines) > 1:
                    status = "warning"
                    warning_count += 1
                    detail = f"{max(len(failed_lines) - 1, 0)} failed services"

            if action_key == "check_critical_logs" and result.ok:
                log_lines = [line for line in result.stdout.splitlines() if line.strip()]
                if log_lines:
                    status = "warning"
                    warning_count += 1
                    detail = f"{len(log_lines)} critical log entries"

            items.append({"name": name, "status": status, "detail": detail})

        overall = "ok"
        if warning_count:
            overall = "warning" if warning_count < len(items) else "error"

        return {"status": overall, "items": items}
