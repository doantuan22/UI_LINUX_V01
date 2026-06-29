# UI Audit - Linux System Assistant

## File UI chính

- `src/sys_assistant/ui/qml/Main.qml`: entry QML hiện hành, tạo `FloatingIcon` và `DesktopOverlay`.
- `src/sys_assistant/ui/qml/FloatingIcon.qml`: trạng thái thu gọn, kéo/thả icon, menu ngữ cảnh, mở dashboard.
- `src/sys_assistant/ui/qml/DesktopOverlay.qml`: dashboard multi-panel hiện hành, bố trí main/tools/process/bottom panels và confirm kill.
- `src/sys_assistant/ui/qml/DashboardWindow.qml`: dashboard cũ/legacy, không được `Main.qml` dùng trực tiếp nhưng vẫn còn trong source.
- `src/sys_assistant/ui/qml/panels/MainMonitorPanel.qml`: header, stat cards, network, power profile.
- `src/sys_assistant/ui/qml/panels/SystemToolsPanel.qml`: 3 công cụ hệ thống và màn hình kết quả.
- `src/sys_assistant/ui/qml/panels/ProcessPanel.qml`: bảng tiến trình, `ListView`, kill confirm.
- `src/sys_assistant/ui/qml/panels/NotificationPanel.qml`: log lỗi/empty state.
- `src/sys_assistant/ui/qml/panels/QuickActionsPanel.qml`: thao tác nhanh ở hàng dưới.
- `src/sys_assistant/ui/qml/panels/MiniSettingsPanel.qml`: toggle cài đặt ở hàng dưới.
- `src/sys_assistant/ui/qml/styles/Theme.qml`: màu glass, text, accent, border.
- `src/sys_assistant/ui/qml/styles/Metrics.qml`: kích thước dashboard, spacing, radius.

## Component tái sử dụng

- `GlassPanel.qml`, `GlassCard.qml`: nền glass, border, shadow.
- `PanelHeader.qml`: tiêu đề panel.
- `StatCard.qml`, `CircularGauge.qml`, `NetworkCard.qml`, `PowerModeButton.qml`: main monitor.
- `ToolActionRow.qml`: row công cụ hệ thống.
- `ProcessRow.qml`: row tiến trình, icon/fallback, kill button.
- `QuickActionButton.qml`: ô thao tác nhanh.
- `ToggleSetting.qml`: row setting/toggle.
- `SystemActionButton.qml`, `ConfirmDialog.qml`: nút và xác nhận.

## Vấn đề thấy từ audit

- `DesktopOverlay.qml` thiếu dim layer phía sau dashboard; panel phụ thuộc nhiều vào opacity từng card.
- `Metrics.qml` chưa có token font/row/button nên nhiều component hard-code font nhỏ 9-11px.
- `MainMonitorPanel.qml` còn label tiếng Anh (`Monitor • Optimize • Protect`, `Performance Mode`) và spacer cuối gây khoảng trống.
- `NetworkCard.qml` còn `Download`/`Upload`.
- `ProcessRow.qml` row 40px, icon 26px, kill button 66px nên chật so với yêu cầu.
- `ProcessPanel.qml` có `ListView` nhưng footer refresh chiếm chiều cao; header/column width cần khớp row.
- `QuickActionsPanel.qml` dùng hàng ngang và button 72px nên label tiếng Việt dễ bị cắt.
- `NotificationPanel.qml` empty state chưa có title `Không có lỗi`, text còn nhỏ.
- `ToggleSetting.qml` đang dùng `Switch` mặc định, chưa đồng bộ glass theme.
- `FloatingIcon.qml`, `DesktopOverlay.qml`, `DashboardWindow.qml`, `SettingsPanel.qml`, `ConfirmDialog.qml` còn một số label tiếng Anh.

## Backend

- `ProcessManager` đã có dữ liệu hiển thị an toàn cho process: `displayName`, `iconName`, `iconPath`, `fallbackLetter`.
- Không cần sửa `CommandManager`, `PermissionManager`, whitelist command hay logic kill process.
