# Command Policy

## Mục tiêu

File này mô tả cách chạy command Linux an toàn trong project.

## CommandManager

Tất cả command phải đi qua `CommandManager`.

API đề xuất:

```python
class CommandManager:
    def run_action(self, action_key: str) -> CommandResult:
        ...
```

Không expose method chạy command raw cho UI.

## CommandResult

```python
@dataclass
class CommandResult:
    ok: bool
    action_key: str
    stdout: str
    stderr: str
    exit_code: int
    message: str
```

## Safe command config

Command được định nghĩa trong `safe_commands.yaml`.

Ví dụ:

```yaml
check_disk:
  command: ["df", "-h"]
  sudo: false
  timeout_sec: 10
  description: "Kiểm tra dung lượng ổ đĩa"
  category: "read"

balanced:
  command: ["powerprofilesctl", "set", "balanced"]
  sudo: false
  timeout_sec: 10
  description: "Chuyển sang chế độ cân bằng"
  category: "performance"
```

## Quy tắc triển khai

- Dùng `subprocess.run`.
- Luôn dùng list command.
- Luôn `shell=False`.
- Luôn có timeout.
- Capture stdout/stderr.
- Không throw exception thẳng lên UI.
- Trả lỗi thân thiện.

## Ví dụ code

```python
import subprocess
from dataclasses import dataclass

@dataclass
class CommandResult:
    ok: bool
    action_key: str
    stdout: str
    stderr: str
    exit_code: int
    message: str

class CommandManager:
    def __init__(self, commands: dict):
        self.commands = commands

    def run_action(self, action_key: str) -> CommandResult:
        if action_key not in self.commands:
            return CommandResult(
                ok=False,
                action_key=action_key,
                stdout="",
                stderr="",
                exit_code=-1,
                message="Action không nằm trong whitelist."
            )

        spec = self.commands[action_key]
        cmd = spec["command"]
        timeout_sec = spec.get("timeout_sec", 10)

        try:
            completed = subprocess.run(
                cmd,
                shell=False,
                capture_output=True,
                text=True,
                timeout=timeout_sec,
                check=False
            )

            return CommandResult(
                ok=completed.returncode == 0,
                action_key=action_key,
                stdout=completed.stdout,
                stderr=completed.stderr,
                exit_code=completed.returncode,
                message="OK" if completed.returncode == 0 else "Command chạy không thành công."
            )

        except FileNotFoundError:
            return CommandResult(
                ok=False,
                action_key=action_key,
                stdout="",
                stderr="",
                exit_code=-1,
                message=f"Không tìm thấy command: {cmd[0]}"
            )

        except subprocess.TimeoutExpired:
            return CommandResult(
                ok=False,
                action_key=action_key,
                stdout="",
                stderr="",
                exit_code=-1,
                message="Command bị timeout."
            )
```

## Action categories

```text
read          Chỉ đọc thông tin
performance   Đổi power profile
cleanup       Xóa cache an toàn
process       Quản lý tiến trình
settings      Thay đổi config app
```

## Các action mặc định

```text
check_disk
check_failed_services
check_critical_logs
check_hardware
check_sensors
power_saver
balanced
performance
clean_thumbnail_cache
```
