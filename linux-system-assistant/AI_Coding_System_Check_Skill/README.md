# AI Coding System Check Skill

Bộ skill này dùng cho AI coding khi cần **kiểm tra hệ thống, kiểm tra chức năng, chạy test, phát hiện lỗi, ghi lại lỗi và nghiệm thu an toàn**.

Mục tiêu chính:

- Kiểm tra đúng vấn đề, không đoán mò.
- Ưu tiên lệnh đọc-only, không phá hệ thống.
- Mọi kết luận phải có bằng chứng: log, output, ảnh chụp, file test, bước tái hiện.
- Phân loại lỗi rõ ràng: hệ thống, môi trường, logic, UI, hiệu năng, quyền truy cập, dependency.
- Sau khi sửa phải chạy lại test hồi quy và ghi kết quả.

## Cách dùng nhanh cho AI coding

1. Đọc `SKILL.md` trước.
2. Đọc protocol tương ứng trong thư mục `protocols/`.
3. Dùng `data/safe_linux_commands.json` để chọn lệnh kiểm tra an toàn.
4. Dùng checklist trong `checklists/` để không bỏ sót bước.
5. Khi phát hiện lỗi, ghi theo `templates/bug_report.md`.
6. Khi kết thúc, xuất báo cáo theo `templates/test_report.md`.

## Nguyên tắc cứng

AI coding không được:

- Chạy lệnh xóa/sửa hệ thống nếu chưa giải thích rõ rủi ro và chưa có xác nhận.
- Tự ý dùng `sudo` cho hành động ghi/sửa.
- Kết luận lỗi khi chưa có bằng chứng.
- Sửa nhiều thứ cùng lúc mà không có baseline trước/sau.
- Bỏ qua test hồi quy sau khi sửa.

AI coding bắt buộc:

- Hiểu mục tiêu kiểm tra trước khi chạy lệnh.
- Ghi lại trạng thái ban đầu.
- Chạy từng nhóm kiểm tra theo thứ tự.
- Đưa ra kết luận có mức độ tin cậy.
- Đề xuất hướng xử lý an toàn, có thể rollback.
