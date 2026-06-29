# TASK 06 - Sửa System Tools Panel

## Mục tiêu

System Tools gọn, rõ, chỉ giữ 3 chức năng.

## Chức năng giữ lại

1. Kiểm tra hệ thống
2. Dọn dẹp hệ thống
3. Thông tin phần cứng

## Việc cần làm

1. Xóa/ẩn các action khác.
2. Mỗi action row có:
   - Icon rõ.
   - Title.
   - Subtitle ngắn.
   - Arrow hoặc trạng thái loading.
3. Click action nào chạy đúng action đó.
4. Có loading state.
5. Có result area hoặc popup kết quả.
6. Row không tràn text.

## Không được

- Không thêm command mới nếu chưa có whitelist.
- Không để `Quản lý tiến trình` trong System Tools.
- Không để `Nhật ký hệ thống` trong System Tools.

## Acceptance criteria

- Panel chỉ còn 3 action.
- Click action chạy đúng chức năng.
- Không overflow.
- Subtitle đọc rõ.
