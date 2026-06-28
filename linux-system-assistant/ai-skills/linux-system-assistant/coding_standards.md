# Coding Standards

## Python

### Style

- Dùng type hints.
- Dùng dataclass cho data result.
- Function nhỏ, rõ nhiệm vụ.
- Không viết logic hệ thống trong UI bridge nếu có thể tách manager.
- Không nuốt exception im lặng.
- Error message nên thân thiện.

### Ví dụ

Tốt:

```python
def get_cpu_usage() -> float:
    return psutil.cpu_percent(interval=None)
```

Không tốt:

```python
def get_everything_and_update_ui_and_run_commands():
    ...
```

## Error handling

Không để app crash nếu:

- Không có GPU.
- Không có sensor nhiệt.
- Không có `powerprofilesctl`.
- Không có `nvidia-smi`.
- Command timeout.
- Process biến mất trước khi kill.

## Logging

Dùng logger service thay vì `print` tràn lan.

Log nên có:

- Info khi app start.
- Warning khi thiếu dependency optional.
- Error khi command fail.
- Action log khi kill/cleanup/performance change.

## QML

### Style

- Component hóa.
- Không copy-paste panel quá nhiều.
- Màu lấy từ `styles/Theme.qml`.
- Kích thước lấy từ `styles/Metrics.qml` nếu có.
- Không hard-code quá nhiều trong từng component.

### Naming

```text
GlassPanel.qml
StatCard.qml
ProcessRow.qml
PowerModeButton.qml
```

### Không làm

- Không chạy logic hệ thống trong QML.
- Không chứa command raw trong QML.
- Không để QML quyết định process nào an toàn để kill.

## Bridge

Bridge chỉ expose các method an toàn:

```python
@Slot(result="QVariant")
def getStats(self): ...

@Slot(int, result="QVariant")
def requestKillProcess(self, pid: int): ...

@Slot(str, result="QVariant")
def setPowerProfile(self, profile: str): ...
```

Bridge phải validate input trước khi gọi manager.

## Config

Config app nên lưu ở:

```text
~/.config/linux-system-assistant/config.json
```

Log app nên lưu ở:

```text
~/.local/state/linux-system-assistant/app.log
```

Cache app nên lưu ở:

```text
~/.cache/linux-system-assistant/
```

## Dependency optional

Các tính năng phụ phải graceful fallback:

- Không có GPU: hiển thị "GPU: unavailable".
- Không có temp sensor: hiển thị "Temp: unavailable".
- Không có fan sensor: ẩn Fan card hoặc hiển thị "N/A".
- Không có performance profile: disable section.
