# Skill: Linux System Assistant

## Mục tiêu

Skill này giúp AI coding hiểu và phát triển project **Linux System Assistant**: một widget/control center nhỏ chạy trên Linux, có giao diện glassmorphism, hiển thị thông số hệ thống và cung cấp một số thao tác an toàn như kiểm tra hệ thống, quản lý tiến trình người dùng, dọn cache an toàn và chuyển đổi chế độ hiệu năng.

App không phải là cửa sổ desktop truyền thống. App hoạt động như một **floating widget**: có icon nhỏ trên màn hình, khi bấm vào sẽ mở dashboard glass nhỏ để xem và điều khiển hệ thống.

## Khi nào dùng skill này

Dùng skill này khi làm các việc sau:

- Tạo project từ đầu.
- Thiết kế kiến trúc source code.
- Viết UI QML/PySide6 theo phong cách glass.
- Viết module đọc CPU, RAM, disk, network, temperature, GPU.
- Viết chức năng quản lý tiến trình an toàn.
- Viết chức năng chạy lệnh Linux qua whitelist.
- Viết chức năng chuyển power profile bằng `powerprofilesctl`.
- Viết chức năng dọn cache an toàn.
- Đóng gói app chạy trên Linux.

## Tư duy phát triển bắt buộc

Luôn ưu tiên:

1. **An toàn hệ thống trước giao diện đẹp.**
2. **Không bao giờ chạy lệnh shell tự do từ input người dùng.**
3. **Mọi lệnh hệ thống phải qua whitelist.**
4. **Không mặc định dùng sudo.**
5. **Kill process phải có xác nhận và chỉ được kill process của user hiện tại.**
6. **UI QML chỉ hiển thị và gọi action key, không tự chứa logic hệ thống nguy hiểm.**
7. **Python backend là nơi xử lý hệ thống.**
8. **Code phải chia module rõ ràng để AI coding dễ mở rộng.**

## Stack mặc định

- Python 3.11+
- PySide6
- Qt Quick / QML
- psutil
- PyYAML
- pynvml, optional cho NVIDIA
- lm-sensors
- power-profiles-daemon / powerprofilesctl
- subprocess với `shell=False`
- PyInstaller hoặc Nuitka cho đóng gói

## Cấu trúc project mục tiêu

```text
linux-system-assistant/
├── README.md
├── pyproject.toml
├── requirements.txt
├── run.sh
├── assets/
│   └── icons/
├── src/
│   └── sys_assistant/
│       ├── main.py
│       ├── app.py
│       ├── bridge.py
│       ├── core/
│       ├── managers/
│       ├── config/
│       ├── services/
│       └── ui/qml/
├── scripts/
├── packaging/
└── tests/
```

## Tài liệu cần đọc theo thứ tự

1. `project_brief.md`
2. `architecture.md`
3. `tech_stack.md`
4. `ui_style_guide.md`
5. `feature_specs.md`
6. `safety_rules.md`
7. `command_policy.md`
8. `mvp_tasks.md`
9. `coding_standards.md`
10. `acceptance_tests.md`

## Quy tắc phản hồi của AI coding khi dùng skill này

Khi được yêu cầu code, AI coding nên:

- Trước tiên đọc `SKILL.md`.
- Nếu tạo project mới, tạo đúng cấu trúc thư mục trong `architecture.md`.
- Nếu viết UI, dùng component trong `ui_style_guide.md`.
- Nếu viết chức năng chạy lệnh, đọc `safety_rules.md` và `command_policy.md`.
- Nếu chưa có file config, tạo từ `templates/safe_commands.yaml` và `templates/protected_processes.yaml`.
- Khi sửa code, không phá kiến trúc module.
- Không thêm lệnh nguy hiểm như `rm -rf /`, `dd`, `mkfs`, `chmod -R 777 /`, `pkill`, `killall`, `sudo kill`, `sudo rm -rf`.
- Không tự ý thêm tính năng cần quyền root nếu chưa có policy rõ ràng.
