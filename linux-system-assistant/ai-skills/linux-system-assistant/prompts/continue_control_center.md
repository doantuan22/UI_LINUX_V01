# Prompt: Continue Control Center

```text
Bạn là AI coding agent đang tiếp tục project Linux System Assistant.

Hãy đọc:
- ai-skills/linux-system-assistant/SKILL.md
- ai-skills/linux-system-assistant/safety_rules.md
- ai-skills/linux-system-assistant/command_policy.md
- ai-skills/linux-system-assistant/feature_specs.md

Nhiệm vụ:
Triển khai MVP phase 3, 4, 5, 6.

Yêu cầu:
1. Process Manager:
   - list top processes theo RAM/CPU
   - chỉ kill process của user hiện tại
   - chặn protected process
   - cần confirm từ UI
   - SIGTERM trước, SIGKILL chỉ sau confirm lần hai

2. Performance Manager:
   - detect powerprofilesctl
   - get current profile
   - list available profiles
   - set power-saver/balanced/performance nếu khả dụng

3. Command Manager:
   - load safe_commands.yaml
   - chỉ chạy action key whitelist
   - subprocess.run với shell=False
   - timeout
   - trả CommandResult

4. Cleanup Manager:
   - chỉ dọn ~/.cache/thumbnails
   - resolve path an toàn
   - tính size trước khi xóa
   - confirm từ UI

Cấm:
- Không os.system
- Không shell=True
- Không sudo kill
- Không pkill/killall
- Không rm -rf path tự do
```
