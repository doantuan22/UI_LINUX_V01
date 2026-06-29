# Function Test Checklist

## Chuẩn bị

- [ ] Đã xác định chức năng cần test.
- [ ] Đã xác định input/output mong đợi.
- [ ] Đã biết precondition.
- [ ] Đã biết cách quan sát kết quả: UI/API/log/file/database.

## Test case bắt buộc

- [ ] Happy path.
- [ ] Empty/null input.
- [ ] Invalid input.
- [ ] Boundary value nếu có ngưỡng.
- [ ] Permission/access nếu có phân quyền.
- [ ] Network/API failure nếu có kết nối mạng.
- [ ] Cancel/close/retry nếu có tác vụ dài.
- [ ] Regression chức năng liên quan.

## UI state

- [ ] Loading state.
- [ ] Success state.
- [ ] Error state.
- [ ] Empty state.
- [ ] Disabled state.
- [ ] Không tràn layout.
- [ ] Không cắt chữ.
- [ ] Scroll hoạt động nếu nội dung dài.
- [ ] Button/icon dễ hiểu.

## Kết thúc

- [ ] Có Pass/Fail/Blocked cho từng test.
- [ ] Có bằng chứng.
- [ ] Có bug report nếu fail.
- [ ] Có test lại sau sửa.
