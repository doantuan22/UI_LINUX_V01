# Kế Hoạch Hoàn Thiện Linux System Assistant

Tài liệu này là brief/roadmap cho AI coding agent tiếp theo. Mục tiêu là đưa project từ mức MVP "chạy được" lên mức ứng dụng Linux thật sự mượt, đẹp, an toàn và dùng được hằng ngày.

## 1. Context Bắt Buộc Cần Đọc Trước

Trước khi sửa code, đọc các file sau theo thứ tự:

1. `README.md`
2. `linux-system-assistant/README.md`
3. `linux-system-assistant/ai-skills/linux-system-assistant/SKILL.md`
4. `linux-system-assistant/ai-skills/linux-system-assistant/architecture.md`
5. `linux-system-assistant/ai-skills/linux-system-assistant/safety_rules.md`
6. `linux-system-assistant/ai-skills/linux-system-assistant/command_policy.md`
7. `linux-system-assistant/ai-skills/linux-system-assistant/ui_style_guide.md`
8. `linux-system-assistant/ai-skills/linux-system-assistant/coding_standards.md`
9. `linux-system-assistant/ai-skills/linux-system-assistant/acceptance_tests.md`
10. `linux-system-assistant/assets/UI_demo.png`

## 2. Mục Tiêu Cuối Cùng

Biến **Linux System Assistant** thành một widget/control center Linux hoàn chỉnh:

- Floating icon kéo thả mượt, không lag, không giật.
- UI gần sát `linux-system-assistant/assets/UI_demo.png`.
- Giao diện có nhiều panel glass độc lập, bố cục chuyên nghiệp, glow vừa phải, trạng thái rõ ràng.
- Các chức năng không chỉ "có nút", mà phải có flow hoàn chỉnh: loading, success, error, confirm, log, fallback.
- Mọi hành động hệ thống phải an toàn, có policy rõ ràng, không gây rủi ro cho máy người dùng.

## 3. Nguyên Tắc An Toàn Không Được Phá

Bắt buộc giữ các rule sau trong mọi phase:

- Không chạy command raw từ UI.
- Không dùng `shell=True`.
- Không dùng `os.system`.
- Không dùng `sudo` mặc định.
- Tất cả command Linux phải đi qua `CommandManager`.
- Tất cả command phải nằm trong whitelist `safe_commands.yaml`.
- QML chỉ gọi action key/method an toàn qua bridge, không chứa logic nguy hiểm.
- Kill process chỉ áp dụng với process của user hiện tại.
- Không kill root process.
- Không kill protected process.
- SIGTERM trước, SIGKILL chỉ sau confirm lần hai.
- Cleanup chỉ được tác động vào path đã được phép, đặc biệt `~/.cache/thumbnails`.
- Không thêm các lệnh nguy hiểm như `rm -rf`, `pkill`, `killall`, `dd`, `mkfs`, `chmod -R 777`, `apt autoremove -y`.

## 4. Hiện Trạng Vấn Đề

Project hiện tại gần như mới đạt mức hiển thị thông số:

- Floating icon kéo trên màn hình còn lag, đơ, giật.
- UI chưa đạt chất lượng như `UI_demo.png`.
- Dashboard hiện tại còn giống một panel MVP, chưa phải control center nhiều vùng.
- Nhiều chức năng có nút/flow cơ bản nhưng chưa hoàn thiện 100%.
- Một số kết quả vẫn hiển thị dạng JSON/debug, chưa có UI result đẹp.
- Cần polish loading/error/empty/success state.
- Cần tăng test cho các manager có tác động hệ thống.

## 5. Phase 1: Audit Nền Tảng

### Mục tiêu

Nắm rõ tình trạng thật của app trước khi refactor lớn.

### Công việc

- Chạy full test hiện tại bằng `pytest`.
- Kiểm tra pyright/qmllint nếu project đã cấu hình sẵn.
- Lập bảng trạng thái từng module:
  - Monitor
  - Process manager
  - Performance mode
  - System check
  - Cleanup
  - Settings/autostart
  - Notifications
  - Packaging
- So sánh UI hiện tại với `assets/UI_demo.png`.
- Chia danh sách component UI còn thiếu/chưa đạt.
- Ghi bug và thiếu sót vào file mới: `linux-system-assistant/roadmap_completion.md`.

### Definition Of Done

- Biết rõ phần nào đang chạy thật, phần nào còn giả, phần nào cần sửa gấp.
- Có checklist ưu tiên cho các phase tiếp theo.
- Không sửa lớn khi chưa audit xong.

## 6. Phase 2: Sửa Lag Floating Icon

### Mục tiêu

Floating icon phải kéo thả mượt, nhẹ, không ghi config liên tục trong lúc drag.

### Nguyên nhân có khả năng cao

Trong `src/sys_assistant/ui/qml/FloatingIcon.qml`:

- `onXChanged` và `onYChanged` đang gọi `saveIconPosition()` liên tục.
- Mỗi pixel di chuyển có thể gọi bridge Python và ghi config xuống disk.
- Icon dùng `GlassPanel`/shadow/effect có thể nặng trong lúc window move.
- Dashboard đang cập nhật `anchorPoint` liên tục trong lúc drag.

### Công việc

- Chỉ lưu vị trí icon trong `onReleased`, không lưu trong `onXChanged/onYChanged`.
- Nếu cần autosave, dùng debounce timer 300-500ms sau khi dừng kéo.
- Trong lúc `dragging`:
  - Tắt shadow/glow nặng.
  - Không animate opacity/scale.
  - Không cập nhật dashboard liên tục.
- Chỉ cập nhật vị trí dashboard sau khi thả icon, hoặc cập nhật với throttle.
- Clamp vị trí icon trong screen bounds.
- Thêm tuỳ chọn `snap to edge` nếu cần, nhưng chỉ animate nhẹ sau khi thả.
- Đảm bảo icon vẫn nhớ vị trí sau restart.

### Definition Of Done

- Kéo icon không giật thấy rõ.
- Không gọi save config liên tục khi drag.
- Icon vẫn nhớ vị trí.
- Wayland/Xwayland không bị mất cửa sổ.

## 7. Phase 3: Nâng UI Gần `UI_demo.png`

### Mục tiêu

Tái cấu trúc UI từ một dashboard MVP thành bộ control center nhiều panel, gần với demo nhất có thể.

### Component cần làm/nâng cấp

#### `FloatingIcon.qml`

- Icon tròn glass.
- Glow xanh/tím nhẹ.
- Tooltip giống demo: `Mở System Assistant`.
- Hover scale nhẹ.
- Trạng thái dragging tối ưu hiệu năng.

#### `DashboardWindow.qml`

- Header giống demo:
  - Icon nhỏ.
  - Title `System Assistant`.
  - Subtitle `Monitor • Optimize • Protect`.
- Nút pin/minimize/close.
- Grid 6 stat cards:
  - CPU
  - GPU
  - RAM
  - Disk
  - CPU Temp
  - Fan Speed
- Network card có download/upload và sparkline.
- Performance mode có 3 nút như demo.
- Bottom action bar có icon + label.

#### `SystemToolsPanel.qml`

Panel bên phải gồm các item:

- Kiểm tra hệ thống.
- Dọn dẹp hệ thống.
- Quản lý tiến trình.
- Thông tin phần cứng.
- Nhật ký hệ thống.

Mỗi item cần có:

- Icon.
- Title.
- Subtitle.
- Chevron.
- Hover/pressed state.
- Loading/error state khi action đang chạy.

#### `ProcessPanel.qml`

- Table rõ ràng:
  - Process
  - CPU
  - RAM
  - Status/action
- Refresh button.
- Sort CPU/RAM.
- Search/filter.
- Protected badge.
- Kill button màu danger.
- Confirm dialog chuẩn.

#### `NotificationsPanel.qml`

- Hiển thị cảnh báo nhiệt độ, disk, RAM, system check warning.
- Có timestamp.
- Có severity: info/warning/error.
- Có cooldown để tránh spam.

#### `QuickActionsPanel.qml`

- Chỉ thêm action nếu policy an toàn rõ.
- Có thể ưu tiên:
  - Lock screen
  - Logout
- Shutdown/restart cần confirm và whitelist riêng, không thêm vội vàng.

#### `SettingsPanel.qml`

- Toggle autostart.
- Theme Glass.
- Auto collapse.
- Show temperature.
- Show network speed.
- Update interval.
- Reset settings.

#### Theme System

- Gom màu vào `styles/Theme.qml`.
- Gom spacing/radius/size vào `styles/Metrics.qml`.
- Không hard-code quá nhiều trong từng component.
- Hạn chế emoji trong UI chính; ưu tiên icon QML/SVG/asset.

### Definition Of Done

- First screen nhìn gần bố cục `UI_demo.png`.
- Không còn cảm giác "form MVP".
- Text không tràn.
- Panel không nhảy layout.
- Có empty/loading/error/success state cho các khu vực chính.

## 8. Phase 4: Hoàn Thiện Monitor

### CPU

- Hiển thị usage, frequency, temperature.
- Nếu thiếu sensor thì hiện `N/A`, không crash.

### GPU

- NVIDIA: ưu tiên `pynvml` hoặc `nvidia-smi` nếu có.
- AMD/Intel: fallback bằng thông tin `lspci`; nếu không lấy được usage thì phân biệt `unsupported` với `unavailable`.
- UI không được giả lập GPU usage nếu không có dữ liệu thật.

### Network

- Sparkline thật, lưu buffer 30-60 điểm.
- Hiển thị download/upload theo interface active.
- Fallback về 0 nếu không đọc được.

### Disk

- Hiển thị root disk mặc định.
- Cảnh báo nếu usage vượt threshold.

### Fan/Battery

- Graceful fallback.
- Theo settings: ẩn card hoặc hiện `N/A`.

### Definition Of Done

- App không crash khi thiếu GPU/sensor/fan/battery.
- Số liệu monitor cập nhật định kỳ và hợp lý.
- UI phân biệt được `N/A`, `unsupported`, `unavailable`.

## 9. Phase 5: Hoàn Thiện Chức Năng Hệ Thống

### System Check

- Chạy từng check riêng.
- Gom summary đẹp thay vì popup JSON.
- Có trạng thái `ok`, `warning`, `error`.
- Có detail view cho logs/services.
- Không tự sửa lỗi hệ thống.

### Cleanup

- Tính size trước khi xóa.
- Confirm rõ ràng.
- Chỉ xóa `~/.cache/thumbnails`.
- Sau cleanup hiện freed size.
- Có log action.

### Performance Mode

- Detect `powerprofilesctl`.
- Lấy profile hiện tại.
- List profile khả dụng.
- Disable button không hỗ trợ.
- Có loading state khi đổi profile.
- Sau khi set thì refresh current profile.

### Process Manager

- Sort CPU/RAM.
- Search/filter.
- Protected badge.
- Không cho kill root/protected.
- SIGTERM trước.
- SIGKILL chỉ sau confirm lần hai.
- Xử lý process biến mất giữa chừng.

### Settings/Autostart

- Config có version/migration nếu cần.
- Validate `update_interval_ms`.
- Autostart `.desktop` phải dùng đúng path `run.sh`.
- Có reset settings.

### Definition Of Done

- Mọi action có loading/success/error.
- Mọi action thay đổi hệ thống có confirm/log.
- Không có action nào vượt qua policy an toàn.

## 10. Phase 6: App Quality, Test, Packaging

### Logging

- App log ở `~/.local/state/linux-system-assistant/app.log`.
- Log action thay đổi hệ thống.
- Không log password/token/thông tin nhạy cảm.

### Notification

- Cooldown chống spam.
- Threshold cấu hình được.
- Notification trong UI trước.
- Desktop notification có thể làm sau, nếu dependency/policy rõ.

### Testing

Cần bổ sung/củng cố test cho:

- Command whitelist.
- Command timeout.
- Cleanup path safety.
- Protected process.
- Root process kill rejection.
- Config/autostart.
- Monitor fallback khi thiếu sensor/GPU.
- Smoke test import/start app.

### Packaging

- `run.sh` ổn định.
- `.desktop` chuẩn.
- Hướng dẫn install/uninstall rõ.
- PyInstaller/Nuitka chỉ làm sau khi app ổn định.

## 11. Thứ Tự Ưu Tiên Để Làm

Làm theo thứ tự này:

1. Audit hiện trạng và tạo `roadmap_completion.md`.
2. Sửa lag floating icon.
3. Refactor UI layout theo `UI_demo.png`.
4. Tách/nâng cấp `SystemToolsPanel`, `ProcessPanel`, `SettingsPanel`.
5. Đổi popup JSON thành result panel đẹp.
6. Hoàn thiện loading/error/success state.
7. Hoàn thiện process/performance/system-check/cleanup.
8. Bổ sung tests cho safety.
9. Polish visual, animation, packaging.

## 12. Việc Nên Làm Ngay Đầu Tiên

Bắt đầu bằng **Phase 2: sửa lag floating icon**.

Lý do:

- Đây là lỗi cảm giác nền tảng của app.
- Nếu icon kéo còn giật thì UI đẹp vẫn không tạo cảm giác cao cấp.
- Nguyên nhân khá rõ: save config quá dày trong lúc drag.
- Phạm vi sửa nhỏ, ít rủi ro, tác động trải nghiệm lớn.

Sau khi icon mượt, mới tiếp tục refactor UI theo `UI_demo.png`.
