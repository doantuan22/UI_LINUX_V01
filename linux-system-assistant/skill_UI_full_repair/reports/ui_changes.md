# UI Changes - Linux System Assistant

## File đã sửa

- `src/sys_assistant/ui/qml/styles/Theme.qml`
- `src/sys_assistant/ui/qml/styles/Metrics.qml`
- `src/sys_assistant/ui/qml/DesktopOverlay.qml`
- `src/sys_assistant/ui/qml/FloatingIcon.qml`
- `src/sys_assistant/ui/qml/DashboardWindow.qml`
- `src/sys_assistant/ui/qml/panels/MainMonitorPanel.qml`
- `src/sys_assistant/ui/qml/panels/SystemToolsPanel.qml`
- `src/sys_assistant/ui/qml/panels/ProcessPanel.qml`
- `src/sys_assistant/ui/qml/panels/NotificationPanel.qml`
- `src/sys_assistant/ui/qml/panels/QuickActionsPanel.qml`
- `src/sys_assistant/ui/qml/SettingsPanel.qml`
- `src/sys_assistant/ui/qml/components/ConfirmDialog.qml`
- `src/sys_assistant/ui/qml/components/GlassPanel.qml`
- `src/sys_assistant/ui/qml/components/NetworkCard.qml`
- `src/sys_assistant/ui/qml/components/NotificationCard.qml`
- `src/sys_assistant/ui/qml/components/PowerModeButton.qml`
- `src/sys_assistant/ui/qml/components/ProcessRow.qml`
- `src/sys_assistant/ui/qml/components/QuickActionButton.qml`
- `src/sys_assistant/ui/qml/components/StatCard.qml`
- `src/sys_assistant/ui/qml/components/SystemActionButton.qml`
- `src/sys_assistant/ui/qml/components/ToggleSetting.qml`
- `src/sys_assistant/ui/qml/components/ToolActionRow.qml`
- `skill_UI_full_repair/reports/ui_audit.md`
- `skill_UI_full_repair/reports/manual_test_result.md`

## Thay đổi UI chính

- Tăng độ đọc bằng `Theme.overlayDim`, `glassPanelStrong`, text secondary/muted sáng hơn, border rõ hơn.
- Thêm font/row/button tokens trong `Metrics.qml` để thống nhất typography và kích thước.
- `DesktopOverlay` có dim layer phía sau panel, hàng dưới cao hơn, main panel gọn hơn.
- Main monitor Việt hóa subtitle/network/performance, rút gọn tên GPU ở UI, bỏ spacer cuối gây trống.
- System Tools chỉ giữ 3 action: `Kiểm tra hệ thống`, `Dọn dẹp hệ thống`, `Thông tin phần cứng`.
- Process panel đưa nút refresh lên header, row cao 46px, icon 30px, kill button 90px.
- Bottom panels: log có empty state rõ, quick actions chuyển grid 2x2, settings dùng toggle glass.
- Floating icon menu và các dialog chính đã Việt hóa.

## Overflow/scroll

- `GlassPanel` mặc định `clip: true`; các panel chính vẫn giữ clip riêng.
- System Tools menu/detail dùng `ScrollView`.
- Process/log dùng `ListView` có scrollbar dọc.
- Quick Actions và Settings dùng `ScrollView`.
- Text dài dùng `elide` hoặc `wrapMode`; button/action row có width ổn định.

## Process icon

- Không sửa backend trong lượt này. `ProcessManager` hiện đã cung cấp `displayName`, `iconName`, `iconPath`, `fallbackLetter`.
- QML ưu tiên `iconPath` để hiển thị icon desktop/theme đã resolve từ backend.
- Nếu không có icon, `ProcessRow` hiển thị fallback circle với chữ cái đầu.

## Safety

- Không thêm command whitelist.
- Không thêm sudo mặc định.
- Không dùng `shell=True` hoặc `os.system`.
- Không sửa `CommandManager`, `PermissionManager`, logic protected process hoặc kill process.
