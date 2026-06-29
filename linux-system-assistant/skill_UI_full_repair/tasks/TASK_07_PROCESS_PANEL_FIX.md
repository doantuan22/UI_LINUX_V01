# TASK 07 - Sửa Process Panel

## Mục tiêu

Process Panel phải trực quan, có icon process, row đẹp, có scroll và không tràn.

## Việc cần làm

1. Dùng `ListView` hoặc `ScrollView` cho danh sách process.
2. Row height 44-48px.
3. Icon size 28-32px.
4. Kill button width 84-96px.
5. Process name dùng `elide: Text.ElideRight`.
6. CPU/RAM columns căn giữa/phải rõ ràng.
7. Header table cách row đầu hợp lý.
8. Nếu process list dài, có scrollbar dọc.
9. Thêm icon process:
   - Ưu tiên icon theme/desktop entry.
   - Mapping process name phổ biến.
   - Fallback circle + chữ cái đầu nếu không có icon.
10. Không làm ảnh hưởng logic kill process.

## Acceptance criteria

- Có icon hoặc fallback cho mỗi process.
- Button `Kết thúc` không bị chật.
- Danh sách dài scroll được.
- Không tràn text/row.
- Kill process vẫn theo confirm/safety hiện có.
