# Báo cáo sơ bộ Project Linux System Assistant

## 1. Tổng quan

Linux System Assistant là ứng dụng widget nổi trên desktop Linux, dùng giao diện glass QML và backend Python. Ứng dụng dùng để xem nhanh thông số máy, quản lý tiến trình, kiểm tra hệ thống, dọn dẹp an toàn và chỉnh một số cài đặt.

## 2. Cấu trúc hệ thống

- `run.sh`: script chạy ứng dụng.
- `src/sys_assistant/app.py`: khởi tạo app PySide6, load QML và tạo system tray.
- `src/sys_assistant/ui/qml/`: giao diện người dùng.
  - `FloatingIcon.qml`: icon nổi khi app thu gọn.
  - `DesktopOverlay.qml`: dashboard chính.
  - `panels/`: các bảng như giám sát, công cụ hệ thống, tiến trình, log, thao tác nhanh, cài đặt.
  - `components/`: component dùng lại như nút, card, toggle, process row.
- `src/sys_assistant/bridge.py`: cầu nối giữa QML UI và Python backend.
- `src/sys_assistant/core/`: lấy thông số hệ thống như CPU, RAM, disk, network, GPU, nhiệt độ, quạt, pin.
- `src/sys_assistant/managers/`: xử lý hành động như command whitelist, tiến trình, quyền, hiệu năng, cleanup cũ.
- `src/sys_assistant/system_tools/`: bộ chức năng công cụ hệ thống mới gồm kiểm tra hệ thống, dọn dẹp, thông tin phần cứng.
- `src/sys_assistant/services/`: polling realtime, log app, notification, autostart.
- `src/sys_assistant/config/`: cấu hình app, whitelist lệnh an toàn, danh sách process được bảo vệ.
- `tests/`: test kiểm tra an toàn và logic backend.

## 3. Luồng hoạt động chính

1. Người dùng chạy `run.sh`.
2. `app.py` tạo `QGuiApplication`, tạo `SysAssistantBridge`, bật polling và load `Main.qml`.
3. UI ban đầu hiện floating icon.
4. Người dùng click icon nổi, dashboard mở ra.
5. QML gọi các hàm trong `bridge.py` để lấy dữ liệu hoặc thực hiện hành động.
6. Backend lấy dữ liệu từ `psutil` hoặc chạy lệnh Linux đã có trong whitelist.
7. Kết quả được gửi ngược về QML để cập nhật giao diện.
8. Polling tự cập nhật thông số hệ thống định kỳ.

## 4. Các chức năng chính

### Giám sát hệ thống

- Hiển thị CPU, GPU, RAM, ổ đĩa, nhiệt độ, quạt, mạng.
- Dữ liệu chủ yếu lấy qua `psutil`.
- GPU NVIDIA có thể lấy thêm bằng `nvidia-smi`.

### Quản lý tiến trình

- Hiển thị danh sách tiến trình, CPU, RAM, icon và trạng thái.
- CPU từng tiến trình lấy từ lệnh `ps`, sau đó chuẩn hóa theo tổng số logical CPU.
- Có nút `Kết thúc`, nhưng vẫn qua confirm và kiểm tra quyền/protected process.

### Công cụ hệ thống

- `Kiểm tra hệ thống`: chạy các lệnh đọc-only như `df`, `free`, `uptime`, `systemctl`, `journalctl`, `lspci`, `lsblk`, `ip`, `sensors`.
- `Dọn dẹp hệ thống`: quét và dọn các cache an toàn theo whitelist.
- `Thông tin phần cứng`: tổng hợp thông tin CPU, GPU, RAM, disk, network, pin.

### Log lỗi

- Chỉ ghi lỗi/cảnh báo runtime của app.
- Không dùng để ghi lỗi của máy tính khi chạy kiểm tra hệ thống.
- Lỗi máy tính được xem trong phần chi tiết của `Kiểm tra hệ thống`.

### Cài đặt

- Lưu vị trí floating icon.
- Bật/tắt autostart.
- Một số tùy chọn hiển thị như nhiệt độ, network speed, auto hide.

## 5. Nguyên tắc an toàn

- UI không chạy lệnh shell tự do.
- Lệnh Linux phải đi qua whitelist trong `safe_commands.yaml`.
- `CommandManager` chạy lệnh với `shell=False`.
- Không dùng sudo mặc định.
- Kill process phải kiểm tra quyền và danh sách protected process.
- Dọn dẹp chỉ thao tác trên các đường dẫn được phép.

## 6. Công nghệ sử dụng

- Python 3.
- PySide6/QML cho giao diện.
- `psutil` để đọc thông số hệ thống.
- YAML cho whitelist command.
- Pytest để kiểm thử.

## 7. Ghi chú hiện tại

- UI đã theo hướng glass dashboard với floating icon.
- Một số test `test_system_tools.py` hiện còn báo thiếu key `swap` và `battery` trong `HardwareInfoCollector`.
- Quick Actions hiện chỉ còn `Khởi động lại` và `Tắt máy`, nhưng đang để disabled vì chưa có backend an toàn/confirm cho hai lệnh này.
