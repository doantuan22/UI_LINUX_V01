# Architecture

## Kiến trúc tổng quát

Project dùng kiến trúc tách biệt rõ:

```text
QML UI
  ↓ gọi action key / nhận data
Python Bridge
  ↓
Core Monitor + Managers
  ↓
Linux system APIs / safe commands
```

## Nguyên tắc kiến trúc

- UI không đọc trực tiếp hệ thống.
- UI không tự chạy command.
- UI chỉ gọi method qua bridge.
- Bridge chuyển request sang manager phù hợp.
- Manager kiểm tra policy trước khi hành động.
- Core module chỉ đọc dữ liệu, không thay đổi hệ thống.
- CommandManager là cổng duy nhất được phép chạy command hệ thống.
- Không dùng `shell=True`.

## Cấu trúc thư mục đề xuất

```text
linux-system-assistant/
├── README.md
├── pyproject.toml
├── requirements.txt
├── run.sh
│
├── assets/
│   ├── icons/
│   └── wallpapers/
│
├── src/
│   └── sys_assistant/
│       ├── main.py
│       ├── app.py
│       ├── bridge.py
│       │
│       ├── core/
│       │   ├── __init__.py
│       │   ├── monitor.py
│       │   ├── cpu.py
│       │   ├── memory.py
│       │   ├── disk.py
│       │   ├── network.py
│       │   ├── temperature.py
│       │   ├── gpu.py
│       │   ├── fan.py
│       │   └── battery.py
│       │
│       ├── managers/
│       │   ├── __init__.py
│       │   ├── process_manager.py
│       │   ├── performance_manager.py
│       │   ├── cleanup_manager.py
│       │   ├── health_checker.py
│       │   ├── command_manager.py
│       │   └── permission_manager.py
│       │
│       ├── config/
│       │   ├── __init__.py
│       │   ├── app_config.py
│       │   ├── safe_commands.yaml
│       │   └── protected_processes.yaml
│       │
│       ├── services/
│       │   ├── __init__.py
│       │   ├── polling_service.py
│       │   ├── notification_service.py
│       │   ├── logger_service.py
│       │   └── autostart_service.py
│       │
│       └── ui/
│           ├── qml.qrc
│           └── qml/
│               ├── Main.qml
│               ├── FloatingIcon.qml
│               ├── DashboardWindow.qml
│               ├── ProcessWindow.qml
│               ├── SettingsWindow.qml
│               ├── components/
│               └── styles/
│
├── scripts/
│   ├── install.sh
│   ├── uninstall.sh
│   ├── create_desktop_file.sh
│   └── detect_system.sh
│
├── packaging/
│   ├── linux-system-assistant.desktop
│   ├── appimage/
│   └── deb/
│
└── tests/
    ├── test_monitor.py
    ├── test_process_manager.py
    └── test_command_manager.py
```

## Vai trò từng layer

### UI Layer

Nằm trong `src/sys_assistant/ui/qml/`.

Nhiệm vụ:

- Hiển thị floating icon.
- Hiển thị dashboard glass.
- Hiển thị stat cards.
- Hiển thị process list.
- Hiển thị settings.
- Gọi bridge method khi người dùng bấm nút.

UI không được:

- Tự chạy command.
- Tự kill process.
- Tự sửa file hệ thống.
- Tự gọi subprocess.

### Bridge Layer

Nằm trong `bridge.py`.

Nhiệm vụ:

- Expose Python method cho QML.
- Nhận request từ QML.
- Gọi core/manager tương ứng.
- Emit signal để QML cập nhật realtime.

Bridge nên có các method:

```python
get_stats()
get_top_processes()
kill_process(pid)
set_power_profile(profile)
run_system_check()
clean_thumbnail_cache()
get_settings()
update_setting(key, value)
```

### Core Layer

Nằm trong `core/`.

Nhiệm vụ:

- Đọc thông tin hệ thống.
- Không thay đổi hệ thống.
- Không gọi lệnh nguy hiểm.
- Trả dữ liệu dạng dict đơn giản.

### Manager Layer

Nằm trong `managers/`.

Nhiệm vụ:

- Xử lý chức năng có hành động.
- Áp dụng safety policy.
- Gọi CommandManager nếu cần command.
- Ghi log thao tác.

### Services Layer

Nằm trong `services/`.

Nhiệm vụ:

- Polling dữ liệu định kỳ.
- Gửi notification.
- Quản lý autostart.
- Ghi log app.

## Data flow cập nhật thông số

```text
PollingService mỗi 1000ms
  ↓
Monitor.collect_all()
  ↓
Bridge.emitStatsUpdated(stats)
  ↓
QML Dashboard update UI
```

## Data flow khi người dùng bấm action

```text
QML Button
  ↓
Bridge method
  ↓
Manager
  ↓
CommandManager hoặc psutil
  ↓
Result
  ↓
Bridge emit result
  ↓
QML hiển thị popup/log
```

## Format dữ liệu stats

```json
{
  "cpu": {
    "usage": 18,
    "temp": 61,
    "freq_ghz": 3.2
  },
  "gpu": {
    "usage": 12,
    "temp": 55,
    "name": "NVIDIA RTX 3060"
  },
  "ram": {
    "usage": 43,
    "used_gb": 6.8,
    "total_gb": 15.9
  },
  "disk": {
    "usage": 38,
    "used_gb": 180,
    "total_gb": 476
  },
  "network": {
    "download_mb_s": 12.4,
    "upload_mb_s": 2.3
  },
  "power_profile": "balanced"
}
```
