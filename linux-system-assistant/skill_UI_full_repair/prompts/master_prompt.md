# Master Prompt - Sửa toàn bộ UI

Hãy đọc toàn bộ thư mục `skill_UI_full_repair/` trước khi sửa code.

Thứ tự đọc bắt buộc:

1. `skill_UI_full_repair/SKILL_UI_FULL_REPAIR.md`
2. `skill_UI_full_repair/00_CURRENT_UI_PROBLEMS.md`
3. `skill_UI_full_repair/01_TARGET_UI_STANDARD.md`
4. `skill_UI_full_repair/02_TASK_ROADMAP.md`
5. Toàn bộ file trong `skill_UI_full_repair/rules/`
6. Các task trong `skill_UI_full_repair/tasks/` theo đúng thứ tự.

Nhiệm vụ: sửa toàn bộ vấn đề hiển thị UI hiện tại của Linux System Assistant.

Các vấn đề cần sửa:

1. Glass panel quá trong, wallpaper làm chữ bị chìm.
2. Chữ phụ quá mờ, font size chưa đều.
3. UI lẫn tiếng Anh/Việt; ưu tiên Việt hóa label.
4. Main Monitor Panel còn khoảng trống thừa, bỏ shortcut buttons dưới cùng.
5. System Tools Panel chỉ giữ 3 chức năng:
   - Kiểm tra hệ thống
   - Dọn dẹp hệ thống
   - Thông tin phần cứng
6. Process Panel phải đẹp hơn:
   - có icon/logo tiến trình hoặc fallback.
   - row cao hơn.
   - kill button không chật.
   - process name elide đúng.
   - danh sách có scroll.
7. Bottom panels bị chật:
   - Error/Log panel có empty state rõ.
   - Quick Actions không được cắt chữ.
   - Settings panel/toggle đẹp hơn.
8. Tất cả panel phải chống overflow:
   - `clip: true`
   - `ScrollView`/`ListView`
   - scrollbar khi cần
   - text elide/wrap.
9. Floating icon/dashboard flow:
   - app khởi động chỉ hiện floating icon.
   - click icon mở dashboard và ẩn icon.
   - click `Thu gọn` đóng dashboard và hiện lại icon.
10. Visual polish:
   - spacing, padding, radius, shadow, hover state đồng nhất.
   - không để panel bị quá chật hoặc quá trống.

Ràng buộc an toàn:

- Ưu tiên sửa QML UI.
- Chỉ sửa Python bridge/backend nếu cần thêm dữ liệu hiển thị như icon process/display name.
- Không dùng `shell=True`.
- Không dùng `os.system`.
- Không thêm sudo mặc định.
- Không thêm command Linux mới nếu chưa có trong whitelist.
- Không làm yếu logic CommandManager, PermissionManager, ProcessManager.
- Không bỏ confirm đối với kill process hoặc quick action nguy hiểm.

Sau khi sửa xong, hãy báo cáo:

1. File đã sửa.
2. Những thay đổi về theme/opacity/contrast.
3. Những thay đổi về layout từng panel.
4. Cách xử lý overflow/scroll.
5. Cách xử lý process icon.
6. Có sửa backend không.
7. Cách test thủ công theo checklist cuối.
