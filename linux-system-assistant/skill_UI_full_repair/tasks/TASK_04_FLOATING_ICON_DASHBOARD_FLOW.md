# TASK 04 - Sửa luồng Floating Icon / Dashboard

## Mục tiêu

Floating icon là trạng thái thu gọn. Dashboard là trạng thái mở rộng. Không hiển thị đồng thời trong flow chính.

## Việc cần làm

1. Khi app khởi động: chỉ hiện floating icon.
2. Khi click floating icon:
   - dashboard/overlay hiện.
   - floating icon ẩn.
3. Trên dashboard có nút `Thu gọn` hoặc `Ẩn app`.
4. Khi click nút thu gọn:
   - dashboard ẩn.
   - floating icon hiện lại đúng vị trí.
5. Nút `Thoát` phải khác nút `Thu gọn`.

## Acceptance criteria

- Dashboard không đè lên icon.
- Người dùng luôn có cách quay về floating icon.
- Không quit app khi bấm thu gọn.
