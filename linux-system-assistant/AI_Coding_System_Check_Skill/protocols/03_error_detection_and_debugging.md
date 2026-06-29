# Protocol 03 — Error Detection & Debugging

## Mục tiêu

Phát hiện lỗi thật, phân biệt cảnh báo với lỗi nghiêm trọng, tìm nguyên nhân gốc và tránh sửa sai triệu chứng.

## Quy trình debug 7 bước

### Bước 1 — Ghi nguyên văn lỗi

Không diễn giải ngay. Ghi lại:

- Thời điểm lỗi.
- Lệnh/thao tác gây lỗi.
- Output đầy đủ hoặc phần quan trọng.
- Screenshot nếu là UI.
- File log liên quan.

### Bước 2 — Phân loại lỗi

Nhóm lỗi:

- Environment: OS, driver, permission, dependency.
- Build: compile, bundler, missing module.
- Runtime: crash, exception, segmentation fault.
- Logic: kết quả sai.
- UI: tràn layout, chữ cắt, tương tác sai.
- Performance: chậm, lag, memory leak, CPU cao.
- Data: sai schema, mất dữ liệu, parse lỗi.
- Network: timeout, 404/500, DNS, CORS.

### Bước 3 — Tạo giả thuyết có kiểm chứng

Format bắt buộc:

```text
Hypothesis: <nguyên nhân nghi ngờ>
Evidence supporting: <bằng chứng ủng hộ>
Evidence missing: <bằng chứng còn thiếu>
Verification: <test/lệnh để xác minh>
Risk if wrong: <rủi ro nếu đoán sai>
```

### Bước 4 — Tái hiện tối thiểu

Tìm cách tạo lỗi với ít bước nhất:

```text
1. Mở app/lệnh...
2. Thực hiện...
3. Quan sát lỗi...
```

Nếu không tái hiện được, ghi `Intermittent` và cần thêm log/tần suất.

### Bước 5 — Khoanh vùng

Chia nhỏ phạm vi:

- Lỗi xảy ra trước hay sau khi user tương tác?
- Frontend hay backend?
- App hay hệ điều hành?
- Dependency hay code nội bộ?
- Một máy hay nhiều máy?
- Chỉ xảy ra khi dữ liệu lớn?

### Bước 6 — Sửa nhỏ nhất

Trước khi sửa, ghi:

- File sẽ sửa.
- Lý do sửa.
- Hành vi mong muốn sau sửa.
- Test xác nhận.

### Bước 7 — Xác minh sau sửa

Chạy lại:

- Test tái hiện lỗi.
- Test chức năng liên quan.
- Test regression.
- Kiểm tra log không còn lỗi mới.

## Anti-pattern cấm

- Thấy lỗi dependency là update toàn bộ dependency ngay.
- Thấy crash là xóa cache/config ngay.
- Thấy UI lỗi là tăng kích thước container bừa.
- Thấy disk đầy là xóa thư mục chưa rõ nguồn gốc.
- Thấy service failed là disable service.
- Thấy permission lỗi là chmod 777.
- Sửa code khi chưa chạy app/test.

## Root Cause Analysis

Dùng mẫu 5-Why ngắn:

```text
Problem: ...
Why 1: ...
Why 2: ...
Why 3: ...
Root cause: ...
Fix: ...
Prevention: ...
```
