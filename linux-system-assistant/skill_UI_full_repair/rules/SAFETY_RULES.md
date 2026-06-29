# Safety Rules

Skill này chủ yếu sửa UI, nhưng vẫn phải giữ an toàn hệ thống.

Không được:
- Dùng `shell=True`.
- Dùng `os.system`.
- Thêm sudo mặc định.
- Thêm command Linux mới ngoài whitelist.
- Xóa hoặc nới lỏng `CommandManager`.
- Xóa hoặc nới lỏng `PermissionManager`.
- Làm yếu logic protected process.
- Bỏ confirm khi kill process hoặc quick action nguy hiểm.

Được phép:
- Thêm field hiển thị như `displayName`, `shortName`, `iconName`, `fallbackLetter`.
- Thêm mapping icon process.
- Thêm tooltip, state loading, state disabled.
- Refactor QML component để đẹp và an toàn hơn.
