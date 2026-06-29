# TASK 08 - Sửa các panel dưới cùng

## Panel cần sửa

- ErrorLogPanel hoặc NotificationPanel.
- QuickActionsPanel.
- MiniSettingsPanel nếu nằm dưới cùng.

## Mục tiêu

Không còn panel thấp/chật, không còn chữ bị cắt.

## Việc cần làm

### Error/Log panel
1. Nếu không có lỗi, hiển thị empty state rõ:
   - `Không có lỗi`
   - `Phiên chạy hiện tại chưa ghi nhận lỗi nghiêm trọng.`
2. Nút `Xóa` chỉ active khi có log.
3. Text không quá mờ.

### Quick Actions
1. Tăng chiều cao panel hoặc đổi layout 2x2.
2. Không để label bị `...`.
3. Dùng label ngắn:
   - `Khởi động lại`
   - `Tắt máy`
   - `Đăng xuất`
   - `Khóa màn hình`
4. Nếu không đủ chỗ, dùng icon-only + tooltip.
5. Action nguy hiểm phải có confirm.

### Settings mini
1. Text không sát toggle.
2. Row height ổn định.
3. Nếu nhiều setting, dùng scroll.

## Acceptance criteria

- Quick Actions không còn chữ bị cắt.
- Error panel có empty state rõ.
- Bottom panels nhìn cân đối.
