# Protocol 02 — Function & Feature Testing

## Mục tiêu

Kiểm tra chức năng của app/hệ thống theo cách có thể tái hiện, đo được và không bỏ sót trạng thái lỗi.

## Quy trình chuẩn

### 1. Xác định chức năng cần test

Với mỗi chức năng, ghi:

- Tên chức năng.
- Mục tiêu người dùng.
- Input.
- Output mong đợi.
- Trạng thái UI/API/DB/log cần thay đổi.
- Trường hợp bình thường.
- Trường hợp biên.
- Trường hợp lỗi.

### 2. Tạo test matrix

Mỗi chức năng phải có ít nhất:

| Nhóm test | Ví dụ | Bắt buộc |
|---|---|---|
| Happy path | Input đúng, thao tác đúng | Có |
| Empty/null | Không có dữ liệu | Có |
| Invalid input | Dữ liệu sai định dạng | Có |
| Boundary | Giá trị sát ngưỡng | Có nếu có ngưỡng |
| Permission | Không đủ quyền | Có nếu có phân quyền |
| Network/API fail | API timeout/lỗi server | Có nếu app dùng mạng |
| Regression | Chức năng cũ không hỏng | Có |

### 3. Kiểm tra UI

AI coding phải kiểm tra:

- Nội dung không tràn khỏi khung.
- Text không bị cắt.
- Nút có trạng thái hover/active/disabled rõ ràng.
- Có loading state khi tác vụ chạy lâu.
- Có empty state khi không có dữ liệu.
- Có error state khi lỗi.
- Có success state khi hoàn tất.
- Có thể thao tác bằng bàn phím nếu cần.
- Responsive với kích thước cửa sổ nhỏ.

### 4. Kiểm tra luồng chức năng

Với mỗi chức năng, ghi theo format:

```text
Function: <tên>
Precondition: <điều kiện ban đầu>
Steps:
  1. ...
  2. ...
Expected:
  - ...
Actual:
  - ...
Status: Pass/Fail/Blocked
Evidence:
  - log/screenshot/output
```

### 5. Kiểm tra lỗi ẩn

Sau khi dùng chức năng, luôn kiểm tra:

- Terminal có warning/error không.
- DevTools console có lỗi không nếu là web/app Electron.
- Log backend có stacktrace không.
- Memory/CPU có tăng bất thường không.
- File tạm/cache có phình bất thường không.

## Tiêu chí pass

Một chức năng chỉ pass khi:

- Đúng output mong đợi.
- Không crash.
- Không lỗi console/log nghiêm trọng.
- UI hiển thị ổn.
- Không làm hỏng chức năng liên quan.
- Có bằng chứng test.
