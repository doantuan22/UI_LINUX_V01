# MVP Tasks

## Mục tiêu MVP

Tạo phiên bản chạy được trên Linux/Kubuntu với:

- Floating icon.
- Dashboard glass.
- Thông số hệ thống thật.
- Process manager cơ bản.
- Power profile switch.
- System check.
- Clean thumbnail cache.
- Settings đơn giản.

## Giai đoạn 0: Khởi tạo project

### Tasks

- [x] Tạo cấu trúc thư mục chuẩn.
- [x] Tạo virtual environment.
- [x] Tạo `requirements.txt`.
- [x] Tạo `main.py`.
- [x] Tạo `app.py`.
- [x] Tạo QML engine.
- [x] Load `Main.qml` thành công.

### Acceptance

- Chạy được `python -m sys_assistant.main`.
- App mở ra cửa sổ QML rỗng hoặc floating icon.

## Giai đoạn 1: UI demo bằng fake data

### Tasks

- [x] Tạo `FloatingIcon.qml`.
- [x] Tạo `DashboardWindow.qml`.
- [x] Tạo `GlassPanel.qml`.
- [x] Tạo `StatCard.qml`.
- [x] Tạo `CircularGauge.qml`.
- [x] Tạo layout giống concept UI.
- [x] Dùng fake data cho CPU/RAM/GPU/Disk/Temp.

### Acceptance

- Click icon mở/đóng dashboard.
- Dashboard có giao diện glass.
- Có ít nhất 6 stat cards.
- UI không bị crash khi resize/mở/đóng.

## Giai đoạn 2: Monitor thật

### Tasks

- [x] Viết `core/cpu.py`.
- [x] Viết `core/memory.py`.
- [x] Viết `core/disk.py`.
- [x] Viết `core/network.py`.
- [x] Viết `core/temperature.py`.
- [x] Viết `core/monitor.py` gom toàn bộ stats.
- [x] Viết `PollingService` update mỗi 1000ms.
- [x] Bridge emit stats sang QML.

### Acceptance

- CPU/RAM/Disk hiển thị số thật.
- Network speed thay đổi theo hoạt động mạng.
- Nhiệt độ hiển thị nếu hệ thống hỗ trợ.
- App không dùng CPU quá cao khi idle.

## Giai đoạn 3: Process Manager

### Tasks

- [x] Viết `process_manager.py`.
- [x] Lấy top process theo RAM/CPU.
- [x] Tạo `ProcessWindow.qml`.
- [x] Tạo `ProcessRow.qml`.
- [x] Thêm confirm dialog khi kill.
- [x] Chặn protected process.
- [x] Chỉ kill process của user hiện tại.

### Acceptance

- Hiển thị danh sách process.
- Kill process user bình thường được.
- Không kill process protected.
- Không dùng sudo kill.

## Giai đoạn 4: Performance Mode

### Tasks

- [x] Viết `performance_manager.py`.
- [x] Detect `powerprofilesctl`.
- [x] Lấy profile hiện tại.
- [x] List profile khả dụng.
- [x] Set power-saver/balanced/performance.
- [x] Update UI theo profile hiện tại.

### Acceptance

- Button Balanced/Performance/Power Saver hoạt động nếu hệ thống hỗ trợ.
- Nếu profile không khả dụng, UI disable button.
- Nếu thiếu command, app báo lỗi thân thiện.

## Giai đoạn 5: System Check

### Tasks

- [x] Tạo `safe_commands.yaml`.
- [x] Viết `command_manager.py`.
- [x] Viết `health_checker.py`.
- [x] Thêm nút Check System.
- [x] Hiển thị kết quả summary.

### Acceptance

- Chạy được check disk.
- Chạy được check failed services.
- Chạy được check critical logs.
- Không có command ngoài whitelist.

## Giai đoạn 6: Cleanup an toàn

### Tasks

- [x] Viết `cleanup_manager.py`.
- [x] Tính size thumbnail cache.
- [x] Thêm confirm dialog.
- [x] Xóa thumbnail cache.
- [x] Trả kết quả xóa được bao nhiêu.

### Acceptance

- Chỉ xóa `~/.cache/thumbnails`.
- Không xóa toàn bộ `~/.cache`.
- Có confirm trước khi xóa.

## Giai đoạn 7: Settings và autostart

### Tasks

- [x] Tạo config file trong `~/.config/linux-system-assistant/config.json`.
- [x] Lưu vị trí floating icon.
- [x] Toggle autostart.
- [x] Tạo `.desktop` file trong `~/.config/autostart`.
- [x] Settings UI.

### Acceptance

- App nhớ vị trí icon.
- Bật/tắt autostart được.
- Config không bị lỗi nếu file chưa tồn tại.

## Giai đoạn 8: Packaging

### Tasks

- [x] Tạo `run.sh`.
- [x] Tạo `.desktop` file.
- [x] Test chạy bằng venv.
- [x] Build bằng PyInstaller hoặc Nuitka.
- [x] Viết hướng dẫn cài/gỡ.

### Acceptance

- Người dùng chạy được bằng một lệnh.
- Có thể tạo shortcut menu.
- Có hướng dẫn uninstall.
