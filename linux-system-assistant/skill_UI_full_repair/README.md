# skill_UI_full_repair

Bộ skill này dùng cho AI coding để sửa lại toàn bộ vấn đề UI hiện tại của Linux System Assistant theo hướng glassmorphism control center.

## Mục tiêu

Sửa các nhóm lỗi UI chính:

1. Nền/panel quá trong, chữ bị chìm vào wallpaper.
2. Panel dưới cùng bị thấp, nội dung và chữ bị cắt.
3. Process Panel chưa đủ đẹp: row chật, nút kill nhỏ, icon chưa đồng đều, cần scroll rõ.
4. Main Monitor Panel còn khoảng trống thừa sau khi bỏ shortcut buttons.
5. Chữ nhỏ, contrast thấp, nhiều text bị `...`.
6. Ngôn ngữ chưa thống nhất giữa tiếng Việt và tiếng Anh.
7. Settings toggle còn giống widget mặc định, chưa đồng bộ glass theme.
8. System Tools cần gọn, chỉ giữ 3 chức năng chính.
9. Floating icon/dashboard phải có luồng mở/ẩn đúng.
10. Tất cả panel phải chống overflow bằng ScrollView/ListView/clip.

## Cách dùng

Copy thư mục `skill_UI_full_repair/` vào root project, sau đó đưa prompt trong:

`prompts/master_prompt.md`

cho AI coding.

AI coding phải đọc:

1. `SKILL_UI_FULL_REPAIR.md`
2. `00_CURRENT_UI_PROBLEMS.md`
3. `01_TARGET_UI_STANDARD.md`
4. `02_TASK_ROADMAP.md`
5. Toàn bộ thư mục `rules/`
6. Các task trong `tasks/` theo đúng thứ tự

## Phạm vi

Ưu tiên sửa QML UI. Chỉ sửa Python bridge/backend khi cần thêm dữ liệu phục vụ UI, ví dụ icon tiến trình hoặc display name.

Không được phá safety logic hiện có.
