# Regression Checklist

Sau mỗi lần sửa, kiểm tra lại các vùng có khả năng bị ảnh hưởng.

## Code-level regression

- [ ] Build vẫn thành công.
- [ ] Lint/typecheck không lỗi mới.
- [ ] Unit test liên quan pass.
- [ ] Không thay đổi API/schema ngoài ý muốn.

## Feature regression

- [ ] Chức năng vừa sửa pass.
- [ ] Chức năng liền kề vẫn pass.
- [ ] Luồng mở/đóng app vẫn đúng.
- [ ] Luồng lỗi vẫn hiển thị đúng.
- [ ] Dữ liệu cũ vẫn đọc được.

## UI regression

- [ ] Không vỡ layout ở cửa sổ nhỏ.
- [ ] Không tràn chữ/nút.
- [ ] Scroll vẫn đúng.
- [ ] Modal/panel không che sai nội dung.
- [ ] Focus/hover/click vẫn đúng.

## System regression

- [ ] Không tăng CPU/RAM bất thường.
- [ ] Không sinh log lỗi mới.
- [ ] Không tạo file tạm quá lớn.
- [ ] Không làm đầy phân vùng root/tmp.
