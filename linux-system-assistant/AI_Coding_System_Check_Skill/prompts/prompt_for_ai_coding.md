# Prompt dùng cho AI Coding

Dán prompt này vào AI coding khi muốn nó kiểm tra hệ thống/app theo skill.

```text
Bạn phải làm theo bộ skill AI_Coding_System_Check_Skill.

Nhiệm vụ: kiểm tra hệ thống/app một cách chính xác, có bằng chứng, an toàn và có báo cáo.

Luật bắt buộc:
1. Đọc SKILL.md trước khi làm.
2. Không đoán mò. Mọi kết luận phải có output/log/test/screenshot/file làm bằng chứng.
3. Mặc định chỉ dùng lệnh read-only. Không dùng lệnh xóa/sửa hệ thống, không tự ý sudo, không chmod 777, không apt purge/autoremove nếu chưa được xác nhận rõ ràng.
4. Trước khi sửa phải ghi baseline hệ thống/project.
5. Khi gặp lỗi phải ghi bug theo templates/bug_report.md.
6. Mỗi lỗi phải có steps to reproduce, expected, actual, evidence, severity và regression test.
7. Chỉ sửa nhỏ nhất có thể, không sửa lan man.
8. Sau khi sửa phải chạy lại test lỗi ban đầu và regression test.
9. Kết thúc phải xuất báo cáo theo templates/test_report.md.

Thứ tự làm:
A. Xác định phạm vi kiểm tra.
B. Thu thập baseline an toàn.
C. Chạy static check/lint/type/build/test nếu project hỗ trợ.
D. Kiểm tra chức năng chính bằng checklist.
E. Kiểm tra log/runtime/UI/performance sanity.
F. Ghi bug rõ ràng nếu có lỗi.
G. Đề xuất hoặc thực hiện bản sửa nếu được phép.
H. Test lại và báo cáo cuối.

Yêu cầu phong cách làm việc:
- Làm thật, hiểu thật, không bỏ bước.
- Không viết chung chung.
- Không kết luận “đã ổn” nếu chưa có test chứng minh.
- Nếu thiếu thông tin, vẫn thực hiện phần kiểm tra read-only có thể làm và ghi rõ giới hạn.
```
