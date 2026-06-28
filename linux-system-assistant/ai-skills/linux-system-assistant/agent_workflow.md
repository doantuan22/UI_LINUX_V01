# Agent Workflow

## Cách AI coding nên làm việc với project này

### Khi bắt đầu

1. Đọc `SKILL.md`.
2. Đọc `project_brief.md`.
3. Đọc `architecture.md`.
4. Xác định đang làm task thuộc phase nào trong `mvp_tasks.md`.
5. Chỉ sửa đúng phạm vi task.

### Khi tạo project từ đầu

AI coding nên tạo theo thứ tự:

1. Cấu trúc thư mục.
2. `requirements.txt`.
3. Python entrypoint.
4. QML entrypoint.
5. Bridge tối thiểu.
6. UI fake data.
7. Monitor thật.
8. Managers.
9. Config.
10. Tests.

### Khi viết UI

1. Tạo component dùng lại trước.
2. Tạo layout bằng fake data.
3. Kết nối bridge sau.
4. Không đưa command vào QML.
5. Test mở/đóng dashboard.

### Khi viết chức năng hệ thống

1. Kiểm tra có cần quyền cao không.
2. Nếu không cần, dùng psutil hoặc command read-only.
3. Nếu cần command, thêm vào whitelist.
4. Không dùng shell=True.
5. Có timeout.
6. Có error handling.
7. Có test.

### Khi viết kill process

1. Lấy process bằng psutil.
2. Kiểm tra owner.
3. Kiểm tra protected list.
4. Confirm từ UI.
5. SIGTERM trước.
6. SIGKILL chỉ nếu có confirm lần hai.

### Khi viết cleanup

1. Resolve path.
2. Kiểm tra path nằm trong home.
3. Kiểm tra path đúng folder được phép.
4. Tính size.
5. Confirm.
6. Xóa.
7. Log.

### Khi thêm command mới

Trước khi thêm command mới, AI coding phải tự hỏi:

- Command này có thay đổi hệ thống không?
- Có cần sudo không?
- Có thể phá dữ liệu không?
- Có cách đọc thông tin bằng psutil thay vì command không?
- Có cần confirm không?
- Có thể giới hạn scope không?

Nếu không chắc, không thêm command.

## Prompt mẫu cho AI coding

```text
Bạn đang làm project Linux System Assistant. Hãy đọc thư mục ai-skills/linux-system-assistant trước. Tuân thủ SKILL.md, architecture.md và safety_rules.md. Nhiệm vụ hiện tại là triển khai MVP phase 1: UI demo bằng PySide6 + QML với fake data. Không viết chức năng chạy lệnh hệ thống trong phase này.
```

## Definition of Done

Một task được xem là xong khi:

- Code chạy được.
- Không phá kiến trúc.
- Không vi phạm safety rules.
- Có error handling.
- Có comment ở phần khó hiểu.
- UI không chứa command raw.
- Nếu có command, command nằm trong whitelist.
- Nếu có action thay đổi hệ thống, có confirm/log.
