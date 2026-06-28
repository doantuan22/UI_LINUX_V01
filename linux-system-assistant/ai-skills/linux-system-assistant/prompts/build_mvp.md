# Prompt: Build MVP

Dùng prompt này cho AI coding khi muốn bắt đầu tạo project.

```text
Bạn là AI coding agent đang xây dựng project Linux System Assistant.

Trước tiên hãy đọc toàn bộ thư mục:
ai-skills/linux-system-assistant/

Tuân thủ bắt buộc:
- SKILL.md
- architecture.md
- safety_rules.md
- command_policy.md
- ui_style_guide.md
- mvp_tasks.md

Nhiệm vụ:
Tạo MVP phase 0 và phase 1.

Yêu cầu:
1. Tạo cấu trúc project Python package chuẩn.
2. Dùng PySide6 + QML.
3. Tạo floating icon.
4. Click icon mở dashboard glass.
5. Dashboard dùng fake data.
6. Có các card CPU, GPU, RAM, Disk, CPU Temp, Fan.
7. Có khu Performance Mode nhưng chưa cần chạy command thật.
8. Có bottom action buttons nhưng chưa cần logic thật.
9. Không chạy bất kỳ command hệ thống nào ở phase này.
10. Không dùng sudo.
11. Không dùng shell=True.
12. Code rõ ràng, có thể mở rộng sang phase 2.

Sau khi tạo xong, hãy ghi lại cách chạy project trong README.md.
```
