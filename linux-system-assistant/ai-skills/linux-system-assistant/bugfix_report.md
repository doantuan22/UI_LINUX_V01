# Báo cáo các chỉnh sửa (Bugfixes & Enhancements)

Tài liệu này ghi nhận các thay đổi quan trọng đã được thực hiện sau khi hoàn thành MVP để khắc phục các lỗi liên quan đến hiển thị giao diện trên môi trường Wayland và QML.

## 1. Khắc phục lỗi ứng dụng chạy ngầm nhưng không hiển thị giao diện

**Nguyên nhân:**
- Môi trường Desktop của người dùng chạy **Wayland**. Wayland có cơ chế bảo mật chặt chẽ, không cho phép cửa sổ ứng dụng (client) tự do thiết lập tọa độ tuyệt đối (`x`, `y`) hoặc kéo thả tự do bằng tọa độ nếu đó là các cửa sổ không có khung (Frameless Window). 
- Trong mã nguồn QML, thành phần `Window` mặc định sẽ bị ẩn nếu không được chỉ định `visible: true`.
- File `Main.qml` sử dụng `Item` làm thẻ gốc. Khi `QQmlApplicationEngine` nạp một `Item`, nó sẽ tự động bao bọc nó bằng một cửa sổ mặc định (dummy window). Điều này gây xung đột làm ẩn các cửa sổ con (`FloatingIcon`).

**Giải pháp đã áp dụng:**
1. **Ép sử dụng backend X11 (Xwayland):** 
   - Sửa file `run.sh`, thêm dòng `export QT_QPA_PLATFORM=xcb` trước khi chạy app.
   - Xwayland hỗ trợ đầy đủ việc định vị tọa độ và kéo thả cho các cửa sổ Frameless.
2. **Kích hoạt hiển thị cho FloatingIcon:**
   - Sửa file `src/sys_assistant/ui/qml/FloatingIcon.qml`, thêm thuộc tính `visible: true` để đảm bảo hệ thống render icon này khi khởi động.
3. **Loại bỏ dummy window trong Main.qml:**
   - Thay thẻ gốc `Item` trong `Main.qml` thành `FloatingIcon`.
   - Lồng `DashboardWindow` trực tiếp vào bên trong `FloatingIcon`. Việc này giúp QML engine nhận diện chính xác cấu trúc đa cửa sổ (multi-window) mà không sinh ra cửa sổ thừa.

## 2. Cập nhật tiến độ MVP

**Hành động:**
- Đã đánh dấu toàn bộ checklist trong `mvp_tasks.md` thành `[x]` (Hoàn thành 100%).
- Các chức năng lấy thông số hệ thống, quản lý tiến trình, chuyển power profile, kiểm tra hệ thống và làm sạch cache đều đã chạy qua kiểm thử tự động (Unit Tests pass 10/10).
