# Prompt: Continue Monitor Implementation

```text
Bạn là AI coding agent đang tiếp tục project Linux System Assistant.

Hãy đọc:
- ai-skills/linux-system-assistant/SKILL.md
- ai-skills/linux-system-assistant/architecture.md
- ai-skills/linux-system-assistant/mvp_tasks.md
- ai-skills/linux-system-assistant/safety_rules.md

Nhiệm vụ:
Triển khai MVP phase 2: monitor thật.

Yêu cầu:
1. Viết module đọc CPU, RAM, Disk, Network bằng psutil.
2. Viết module đọc nhiệt độ bằng psutil.sensors_temperatures(), nếu không có thì trả None.
3. Viết Monitor.collect_all() trả dict đúng format trong architecture.md.
4. Viết PollingService cập nhật mỗi 1000ms.
5. Kết nối Bridge emit stats sang QML.
6. UI phải hiển thị N/A nếu thiếu dữ liệu.
7. Không triển khai command hệ thống trong phase này.
8. Không dùng sudo.
9. Không dùng shell=True.
```
