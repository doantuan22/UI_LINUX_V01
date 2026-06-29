Hãy đọc `skill_UI_full_repair/SKILL_UI_FULL_REPAIR.md` và thực hiện toàn bộ task trong `skill_UI_full_repair/tasks/`.

Tập trung sửa UI:
- Tăng opacity/contrast glass panel để chữ không bị chìm vào wallpaper.
- Chuẩn hóa font size và Việt hóa label.
- Chống overflow toàn bộ panel bằng clip, ScrollView/ListView, elide/wrap.
- Sửa floating icon flow: click icon mở dashboard và ẩn icon, click Thu gọn đóng dashboard và hiện lại icon.
- Main panel bỏ shortcut buttons dưới cùng và cân lại khoảng trống.
- System Tools chỉ giữ 3 chức năng: Kiểm tra hệ thống, Dọn dẹp hệ thống, Thông tin phần cứng.
- Process Panel có icon/fallback icon, row đẹp, kill button không chật, list có scroll.
- Bottom panels không bị cắt chữ; Quick Actions phải hiển thị đầy đủ label.
- Settings toggle phải đồng bộ glass theme.

Không dùng shell=True, os.system, sudo mặc định, không thêm command ngoài whitelist.
