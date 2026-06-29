# TASK 03 - Chống overflow toàn bộ panel

## Mục tiêu

Không panel nào được để nội dung tràn khỏi khung.

## Việc cần làm

1. Tất cả panel chính/phụ phải có `clip: true`.
2. Panel có danh sách dài phải dùng `ScrollView` hoặc `ListView`.
3. Thêm scrollbar:
   - `ScrollBar.vertical.policy: ScrollBar.AsNeeded`
   - `ScrollBar.horizontal.policy: ScrollBar.AsNeeded` nếu cần.
4. Row/list/table phải có width ràng buộc theo parent.
5. Button phải có width ổn định, không vượt khung.
6. Text dài phải elide hoặc wrap.
7. Kiểm tra các panel:
   - SystemToolsPanel
   - ProcessPanel
   - ErrorLogPanel/NotificationPanel
   - QuickActionsPanel
   - MiniSettingsPanel

## Acceptance criteria

- Không còn nội dung tràn khỏi panel.
- Nội dung dài xem được bằng scroll.
- Không còn chữ bị cắt do container quá thấp nếu có thể tránh.
