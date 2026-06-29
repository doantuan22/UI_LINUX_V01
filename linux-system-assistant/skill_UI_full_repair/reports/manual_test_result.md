# Manual Test Notes

## Đã kiểm tra bằng tool

- Parse QML bằng PySide6 `QQmlComponent`: 28 file QML pass.
- Test Python/safety: `PYTHONPATH=src .venv/bin/python -m pytest` pass 36/36.

## Checklist test thủ công đề xuất

- Khởi động app, xác nhận chỉ thấy floating icon.
- Click floating icon, dashboard mở và floating icon ẩn.
- Click `Thu gọn`, dashboard đóng và floating icon hiện lại.
- Click `Thoát`, app thoát; không nhầm với `Thu gọn`.
- Kiểm tra panel trên wallpaper sáng/tối: chữ chính/phụ đủ đọc.
- Main panel không còn shortcut buttons dưới cùng; không còn khoảng trống lớn.
- Network hiển thị `Tải xuống`/`Tải lên`; performance hiển thị `Chế độ hiệu năng`.
- System Tools chỉ có 3 action và từng action mở detail/result đúng.
- Process list có scrollbar khi dài; mỗi row có icon hoặc fallback letter.
- Kill button `Kết thúc` không bị chật và vẫn mở confirm trước khi kill.
- Log panel khi không có lỗi hiển thị `Không có lỗi`.
- Quick Actions hiển thị đủ: `Khởi động lại`, `Tắt máy`, `Đăng xuất`, `Khóa màn hình`.
- Settings toggle có style glass/cyan, không sát mép, bấm ổn định.
