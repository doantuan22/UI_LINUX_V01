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

- [ ] Tạo cấu trúc thư mục chuẩn.
- [ ] Tạo virtual environment.
- [ ] Tạo `requirements.txt`.
- [ ] Tạo `main.py`.
- [ ] Tạo `app.py`.
- [ ] Tạo QML engine.
- [ ] Load `Main.qml` thành công.

### Acceptance

- Chạy được `python -m sys_assistant.main`.
- App mở ra cửa sổ QML rỗng hoặc floating icon.

## Giai đoạn 1: UI demo bằng fake data

### Tasks

- [ ] Tạo `FloatingIcon.qml`.
- [ ] Tạo `DashboardWindow.qml`.
- [ ] Tạo `GlassPanel.qml`.
- [ ] Tạo `StatCard.qml`.
- [ ] Tạo `CircularGauge.qml`.
- [ ] Tạo layout giống concept UI.
- [ ] Dùng fake data cho CPU/RAM/GPU/Disk/Temp.

### Acceptance

- Click icon mở/đóng dashboard.
- Dashboard có giao diện glass.
- Có ít nhất 6 stat cards.
- UI không bị crash khi resize/mở/đóng.

## Giai đoạn 2: Monitor thật

### Tasks

- [ ] Viết `core/cpu.py`.
- [ ] Viết `core/memory.py`.
- [ ] Viết `core/disk.py`.
- [ ] Viết `core/network.py`.
- [ ] Viết `core/temperature.py`.
- [ ] Viết `core/monitor.py` gom toàn bộ stats.
- [ ] Viết `PollingService` update mỗi 1000ms.
- [ ] Bridge emit stats sang QML.

### Acceptance

- CPU/RAM/Disk hiển thị số thật.
- Network speed thay đổi theo hoạt động mạng.
- Nhiệt độ hiển thị nếu hệ thống hỗ trợ.
- App không dùng CPU quá cao khi idle.

## Giai đoạn 3: Process Manager

### Tasks

- [ ] Viết `process_manager.py`.
- [ ] Lấy top process theo RAM/CPU.
- [ ] Tạo `ProcessWindow.qml`.
- [ ] Tạo `ProcessRow.qml`.
- [ ] Thêm confirm dialog khi kill.
- [ ] Chặn protected process.
- [ ] Chỉ kill process của user hiện tại.

### Acceptance

- Hiển thị danh sách process.
- Kill process user bình thường được.
- Không kill process protected.
- Không dùng sudo kill.

## Giai đoạn 4: Performance Mode

### Tasks

- [ ] Viết `performance_manager.py`.
- [ ] Detect `powerprofilesctl`.
- [ ] Lấy profile hiện tại.
- [ ] List profile khả dụng.
- [ ] Set power-saver/balanced/performance.
- [ ] Update UI theo profile hiện tại.

### Acceptance

- Button Balanced/Performance/Power Saver hoạt động nếu hệ thống hỗ trợ.
- Nếu profile không khả dụng, UI disable button.
- Nếu thiếu command, app báo lỗi thân thiện.

## Giai đoạn 5: System Check

### Tasks

- [ ] Tạo `safe_commands.yaml`.
- [ ] Viết `command_manager.py`.
- [ ] Viết `health_checker.py`.
- [ ] Thêm nút Check System.
- [ ] Hiển thị kết quả summary.

### Acceptance

- Chạy được check disk.
- Chạy được check failed services.
- Chạy được check critical logs.
- Không có command ngoài whitelist.

## Giai đoạn 6: Cleanup an toàn

### Tasks

- [ ] Viết `cleanup_manager.py`.
- [ ] Tính size thumbnail cache.
- [ ] Thêm confirm dialog.
- [ ] Xóa thumbnail cache.
- [ ] Trả kết quả xóa được bao nhiêu.

### Acceptance

- Chỉ xóa `~/.cache/thumbnails`.
- Không xóa toàn bộ `~/.cache`.
- Có confirm trước khi xóa.

## Giai đoạn 7: Settings và autostart

### Tasks

- [ ] Tạo config file trong `~/.config/linux-system-assistant/config.json`.
- [ ] Lưu vị trí floating icon.
- [ ] Toggle autostart.
- [ ] Tạo `.desktop` file trong `~/.config/autostart`.
- [ ] Settings UI.

### Acceptance

- App nhớ vị trí icon.
- Bật/tắt autostart được.
- Config không bị lỗi nếu file chưa tồn tại.

## Giai đoạn 8: Packaging

### Tasks

- [ ] Tạo `run.sh`.
- [ ] Tạo `.desktop` file.
- [ ] Test chạy bằng venv.
- [ ] Build bằng PyInstaller hoặc Nuitka.
- [ ] Viết hướng dẫn cài/gỡ.

### Acceptance

- Người dùng chạy được bằng một lệnh.
- Có thể tạo shortcut menu.
- Có hướng dẫn uninstall.
