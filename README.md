# Báo Cáo Hiện Trạng Linux System Assistant

## 1. Cấu Trúc Hệ Thống Hiện Tại

Linux System Assistant là ứng dụng/widget Linux viết bằng **Python + PySide6/QML**. Ứng dụng chạy dưới dạng floating icon, khi bấm vào sẽ mở dashboard dạng control center.

Cấu trúc chính:

- `linux-system-assistant/src/sys_assistant/app.py`: khởi tạo `QGuiApplication`, QML engine, system tray và bridge.
- `linux-system-assistant/src/sys_assistant/main.py`: entrypoint, có chặn chạy app bằng quyền root.
- `linux-system-assistant/src/sys_assistant/bridge.py`: cầu nối giữa QML UI và backend Python.
- `linux-system-assistant/src/sys_assistant/core/`: đọc thông số hệ thống như CPU, RAM, Disk, Network, Temperature, GPU, Fan, Battery.
- `linux-system-assistant/src/sys_assistant/managers/`: xử lý các hành động hệ thống như process kill, performance mode, system check, cleanup, command whitelist.
- `linux-system-assistant/src/sys_assistant/services/`: polling realtime, logging, notification, autostart.
- `linux-system-assistant/src/sys_assistant/config/`: cấu hình app, whitelist command, danh sách protected process.
- `linux-system-assistant/src/sys_assistant/ui/qml/`: giao diện QML.

Kiến trúc hoạt động:

```text
QML UI -> SysAssistantBridge -> Core/Managers/Services -> psutil hoặc CommandManager
```

Mọi lệnh Linux có tương tác hệ thống đi qua `CommandManager`, dùng whitelist trong `safe_commands.yaml`, chạy với `shell=False`, timeout rõ ràng và không dùng sudo mặc định.

## 2. Các Chức Năng Hệ Thống Hiện Tại

Các chức năng đang có:

- **Giám sát hệ thống realtime:** CPU, RAM, Disk, Network, nhiệt độ CPU, GPU, Fan, Battery, power profile.
- **GPU detection:** ưu tiên `pynvml`, fallback qua `nvidia-smi`, cuối cùng dùng `lspci` để nhận diện GPU không hỗ trợ usage.
- **System Check:** chạy các action whitelist gồm `df -h`, `systemctl --failed`, `journalctl -p 3 -xb --no-pager`, `lspci`, `lsblk`, `sensors`.
- **Performance Mode:** đọc, liệt kê và chuyển profile bằng `powerprofilesctl`.
- **Process Manager:** lấy top process của user hiện tại, hiển thị CPU/RAM, protected badge, kill bằng SIGTERM trước và SIGKILL sau xác nhận lần hai.
- **Cleanup:** tính dung lượng và dọn `~/.cache/thumbnails`; có chặn symlink và chỉ xóa nội dung bên trong thư mục cache.
- **Settings:** lưu autostart, update interval, theme, vị trí floating icon, show temperature, show network speed, safe mode process kill.
- **Autostart:** tạo/xóa file `.desktop` trong `~/.config/autostart`, có confirm từ UI và chặn file đích là symlink.
- **Logging:** ghi log app/action vào `~/.local/state/linux-system-assistant/app.log`.

## 3. Luồng Hoạt Động Chính Của Hệ Thống

Luồng khởi động:

```text
run.sh -> python -m sys_assistant.main -> app.run()
-> tạo QGuiApplication
-> tạo SysAssistantBridge
-> start PollingService
-> load Main.qml
-> hiển thị FloatingIcon
```

Luồng cập nhật thông số:

```text
PollingService -> SystemMonitor.collect_all()
-> đọc core metrics bằng psutil/CommandManager
-> Bridge emit statsUpdated
-> DashboardWindow.applyStats()
-> cập nhật stat cards, network card, power profile UI
```

Luồng thao tác hệ thống:

```text
QML action -> SysAssistantBridge slot
-> manager tương ứng
-> CommandManager hoặc psutil
-> trả result
-> UI hiển thị popup/trạng thái
```

Luồng kill process:

```text
ProcessPanel -> ConfirmDialog
-> bridge.killProcess(pid, force=false)
-> PermissionManager kiểm owner/protected/root
-> gửi SIGTERM
-> nếu còn sống, UI hỏi Force Kill
-> bridge.killProcess(pid, force=true)
-> backend chỉ cho SIGKILL nếu đã có SIGTERM trước đó
```

## 4. UI Hiện Tại Của Phần Mềm

### 4.1. Cấu Trúc UI Hiện Tại

UI hiện tại dùng QML theo phong cách glassmorphism. Giao diện chính gồm:

- `Main.qml`: root QML, tạo `FloatingIcon` và lồng `DashboardWindow`.
- `FloatingIcon.qml`: icon nổi frameless, luôn nổi trên màn hình, có thể kéo thả, click để mở/đóng dashboard, có menu chuột phải.
- `DashboardWindow.qml`: cửa sổ dashboard glass, dạng 2 cột.
- `SystemToolsPanel.qml`: panel công cụ hệ thống.
- `ProcessPanel.qml`: panel danh sách tiến trình.
- `SettingsPanel.qml`: panel cài đặt.
- Components dùng lại: `GlassPanel`, `GlassCard`, `StatCard`, `CircularGauge`, `NetworkCard`, `PowerModeButton`, `SystemActionButton`, `ConfirmDialog`.
- Style dùng chung: `styles/Theme.qml` và `styles/Metrics.qml`.

### 4.2. Cấu Trúc Vị Trí Hiển Thị Của UI

Vị trí tổng thể:

- **Floating Icon:** cửa sổ nhỏ kích thước theo `Metrics.iconSize`, mặc định lấy vị trí từ config `floating_icon`. Khi kéo thả, vị trí được lưu lại qua bridge.
- **Dashboard:** xuất hiện cạnh floating icon, tọa độ dựa trên `anchorPoint`: nằm bên phải icon và lệch lên nhẹ.

Bố cục dashboard:

```text
DashboardWindow
├── Cột trái: Main Monitor
│   ├── Header: icon, title "System Assistant", subtitle "Monitor • Optimize • Protect"
│   ├── Nút Hide và Quit
│   ├── Grid 6 stat cards: CPU, GPU, RAM, Disk, Temp, Fan
│   ├── NetworkCard: download/upload speed
│   └── Performance Mode: Power Saver, Balanced, Performance
│
└── Cột phải: Sidebar
    ├── Tab buttons: Tools, Processes, Settings
    └── Nội dung theo tab:
        ├── Tools: Check System, Clean Cache
        ├── Processes: search, table process, CPU/RAM, Kill button
        └── Settings: Autostart, Show temperature, Show network speed, Safe mode process kill
```

Các popup/confirm hiện có:

- Popup kết quả System Check.
- Popup trạng thái thao tác.
- Confirm kill process.
- Confirm force kill.
- Confirm clean thumbnail cache.
- Confirm bật autostart.

## 5. Ghi Chú Trạng Thái

Hệ thống hiện tại đã tập trung mạnh vào hướng **safety-first**:

- Không chạy lệnh shell tự do từ UI.
- Không dùng `shell=True`.
- Không dùng sudo mặc định.
- Có whitelist command.
- Có chặn root process, protected process và self-kill.
- Cleanup chỉ giới hạn trong thumbnail cache.
- App bị chặn nếu chạy bằng quyền root.
