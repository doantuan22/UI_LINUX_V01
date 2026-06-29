# SKILL_UI_FULL_REPAIR

## Vai trò của skill

Skill này là tài liệu điều phối cho AI coding khi sửa toàn bộ UI của Linux System Assistant. Mục tiêu không phải thêm chức năng mới, mà là làm UI hiện tại hiển thị đúng, dễ đọc, gọn, đẹp và giống một glassmorphism control center hơn.

## Project context

Project là app/widget Linux dùng Python + PySide6/QML.

UI hiện tại đã có dạng multi-panel glass:
- Floating icon.
- Main monitor panel.
- System tools panel.
- Process manager panel.
- Error log panel.
- Quick actions panel.
- Settings panel.

Tuy nhiên UI còn lỗi về opacity, overflow, spacing, typography, text clipping, localization và visual hierarchy.

## Nguyên tắc sửa

1. Sửa từ design system trước, sau đó mới sửa từng panel.
2. Không hard-code lung tung nếu có thể đưa vào `Theme.qml` hoặc `Metrics.qml`.
3. Mọi panel phải có padding, clip và cơ chế scroll khi nội dung dài.
4. Text không được bị cắt khó hiểu.
5. Không để wallpaper làm chữ khó đọc.
6. Ngôn ngữ UI phải thống nhất, ưu tiên tiếng Việt.
7. Component dùng lại phải được chuẩn hóa.
8. Không sửa backend safety logic nếu không cần.
9. Không thêm command hệ thống mới ngoài whitelist.
10. Không dùng `shell=True`, `os.system`, sudo mặc định.

## File QML ưu tiên kiểm tra

- `src/sys_assistant/ui/qml/Main.qml`
- `src/sys_assistant/ui/qml/FloatingIcon.qml`
- `src/sys_assistant/ui/qml/DashboardWindow.qml`
- `src/sys_assistant/ui/qml/DesktopOverlay.qml`
- `src/sys_assistant/ui/qml/panels/MainMonitorPanel.qml`
- `src/sys_assistant/ui/qml/panels/SystemToolsPanel.qml`
- `src/sys_assistant/ui/qml/panels/ProcessPanel.qml`
- `src/sys_assistant/ui/qml/panels/ErrorLogPanel.qml`
- `src/sys_assistant/ui/qml/panels/NotificationPanel.qml`
- `src/sys_assistant/ui/qml/panels/QuickActionsPanel.qml`
- `src/sys_assistant/ui/qml/panels/MiniSettingsPanel.qml`
- `src/sys_assistant/ui/qml/components/GlassPanel.qml`
- `src/sys_assistant/ui/qml/components/GlassCard.qml`
- `src/sys_assistant/ui/qml/components/StatCard.qml`
- `src/sys_assistant/ui/qml/components/CircularGauge.qml`
- `src/sys_assistant/ui/qml/components/ProcessRow.qml`
- `src/sys_assistant/ui/qml/components/SystemActionRow.qml`
- `src/sys_assistant/ui/qml/components/ToggleSetting.qml`
- `src/sys_assistant/ui/qml/styles/Theme.qml`
- `src/sys_assistant/ui/qml/styles/Metrics.qml`

## File backend chỉ sửa nếu cần

- `src/sys_assistant/bridge.py`
- `src/sys_assistant/managers/process_manager.py`
- `src/sys_assistant/core/gpu.py`

Chỉ sửa backend để thêm trường hiển thị an toàn:
- `displayName`
- `shortName`
- `iconName`
- `iconPath`
- `fallbackLetter`

Không sửa logic kill process, permission, command whitelist trừ khi có lỗi rõ ràng.
