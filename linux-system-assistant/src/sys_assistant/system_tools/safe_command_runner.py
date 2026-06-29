"""Safe command runner: executes only whitelisted read-only commands."""

from __future__ import annotations

import shutil
import subprocess
from dataclasses import dataclass, field
from typing import Any

from sys_assistant.system_tools.status import ERROR, OK, TIMEOUT, UNKNOWN


# Maximum characters of stdout to retain
_MAX_OUTPUT_CHARS = 5000

# Commands that must never be executed
_FORBIDDEN_BINARIES = frozenset({
    "rm", "rmdir", "mv", "cp", "chmod", "chown", "dd", "mkfs", "fsck",
    "mount", "umount", "kill", "killall", "pkill", "reboot", "shutdown",
})


@dataclass(frozen=True)
class CommandSpec:
    """Immutable specification for a whitelisted command."""
    id: str
    title: str
    command: list[str]
    timeout_seconds: int = 5
    required: bool = True
    section: str = ""
    run_if_available: str | None = None


@dataclass
class CommandRunResult:
    """Result from running a safe command."""
    spec_id: str
    status: str
    stdout: str = ""
    stderr: str = ""
    exit_code: int = -1
    error_message: str = ""


class SafeCommandRunner:
    """Runs commands from a predefined whitelist only. No user input accepted."""

    def run(self, spec: CommandSpec) -> CommandRunResult:
        """Execute a single whitelisted command spec."""
        # Validate command binary isn't forbidden
        binary = spec.command[0] if spec.command else ""
        if binary in _FORBIDDEN_BINARIES:
            return CommandRunResult(
                spec_id=spec.id,
                status=ERROR,
                error_message=f"Command bị cấm: {binary}",
            )

        # Check optional command availability
        if spec.run_if_available:
            if shutil.which(spec.run_if_available) is None:
                return CommandRunResult(
                    spec_id=spec.id,
                    status=UNKNOWN,
                    error_message=f"Không tìm thấy: {spec.run_if_available}",
                )

        try:
            completed = subprocess.run(
                spec.command,
                shell=False,
                capture_output=True,
                text=True,
                timeout=spec.timeout_seconds,
                check=False,
            )
            stdout = completed.stdout[:_MAX_OUTPUT_CHARS] if completed.stdout else ""
            stderr = completed.stderr[:_MAX_OUTPUT_CHARS] if completed.stderr else ""

            if completed.returncode == 0:
                return CommandRunResult(
                    spec_id=spec.id,
                    status=OK,
                    stdout=stdout,
                    stderr=stderr,
                    exit_code=completed.returncode,
                )
            else:
                return CommandRunResult(
                    spec_id=spec.id,
                    status=ERROR,
                    stdout=stdout,
                    stderr=stderr,
                    exit_code=completed.returncode,
                    error_message=f"Exit code: {completed.returncode}",
                )

        except FileNotFoundError:
            return CommandRunResult(
                spec_id=spec.id,
                status=UNKNOWN,
                error_message=f"Không tìm thấy command: {binary}",
            )
        except subprocess.TimeoutExpired:
            return CommandRunResult(
                spec_id=spec.id,
                status=TIMEOUT,
                error_message=f"Timeout sau {spec.timeout_seconds}s",
            )
        except OSError as exc:
            return CommandRunResult(
                spec_id=spec.id,
                status=ERROR,
                error_message=f"Lỗi hệ thống: {exc}",
            )
