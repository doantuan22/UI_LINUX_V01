# Protocol 06 — Quality Gates & Acceptance

## Mục tiêu

Đặt cổng chất lượng để AI coding không kết thúc nhiệm vụ khi chưa kiểm tra đủ.

## Quality Gate 1 — Safety Gate

Pass khi:

- Không chạy lệnh phá hủy.
- Không tự ý dùng `sudo` để sửa.
- Không thay đổi file hệ thống ngoài phạm vi.
- Có baseline trước khi sửa.

Fail khi:

- Đề xuất `chmod 777`.
- Xóa cache/log không có bằng chứng.
- Tắt service không rõ vai trò.
- Sửa config hệ thống không rollback.

## Quality Gate 2 — Evidence Gate

Pass khi mỗi kết luận có bằng chứng.

Fail khi:

- “Có vẻ ổn” nhưng không có test.
- “Do driver” nhưng không có log/command chứng minh.
- “Đã sửa” nhưng chưa chạy lại lỗi ban đầu.

## Quality Gate 3 — Function Gate

Pass khi:

- Chức năng chính chạy đúng.
- Error/loading/empty state có xử lý.
- Không có lỗi console/log nghiêm trọng.
- UI không tràn/cắt chữ.

## Quality Gate 4 — Test Gate

Pass khi đã chạy tối thiểu:

- Lint/type/build nếu project hỗ trợ.
- Unit/integration nếu có.
- Smoke test.
- Manual test cho luồng chính.
- Regression test cho vùng đã sửa.

## Quality Gate 5 — Report Gate

Pass khi báo cáo cuối có:

- Môi trường.
- Test đã chạy.
- Kết quả.
- Lỗi phát hiện.
- Lỗi đã sửa.
- Bằng chứng.
- Rủi ro còn lại.

## Definition of Done

```text
[ ] Baseline đã ghi
[ ] Lệnh/test đã chạy có output
[ ] Lỗi được phân loại severity
[ ] Có root cause hoặc giả thuyết có kiểm chứng
[ ] Đã sửa nhỏ nhất có thể
[ ] Đã test lại lỗi ban đầu
[ ] Đã chạy regression
[ ] Không phát sinh lỗi nghiêm trọng mới
[ ] Có báo cáo cuối
```
