# Project Brief

## Tên project

**Linux System Assistant**

Có thể đổi tên thương hiệu sau này thành:

- SysDock
- GlassSys
- DeskPilot
- KControl Lite
- NeoMonitor
- Linux Mini Control Center

## Mô tả ngắn

Linux System Assistant là một app/widget nhỏ cho Linux, có giao diện glassmorphism, nằm dưới dạng icon nổi trên desktop. Khi người dùng bấm vào icon, một dashboard nhỏ hiện ra để hiển thị thông số máy và cung cấp các thao tác hệ thống an toàn.

## Vấn đề cần giải quyết

Người dùng Linux thường phải mở nhiều app/lệnh khác nhau để xem:

- CPU usage
- GPU usage
- RAM usage
- Disk usage
- Nhiệt độ CPU/GPU
- Network speed
- Process dùng nhiều tài nguyên
- Trạng thái hiệu năng
- Lỗi service/log hệ thống

Project này gom các thông tin và thao tác thường dùng vào một panel nhỏ, đẹp và dễ dùng.

## Đối tượng người dùng

- Người dùng Linux desktop.
- Người dùng Kubuntu/KDE.
- Người chơi game trên Linux.
- Lập trình viên muốn theo dõi tài nguyên hệ thống.
- Người dùng muốn thao tác nhanh mà không phải nhớ nhiều lệnh terminal.

## Hệ điều hành ưu tiên

Ưu tiên phát triển cho:

- Kubuntu/KDE Plasma
- Ubuntu-based distro
- Debian-based distro

Sau này có thể mở rộng sang:

- Arch Linux
- Fedora
- openSUSE

## Trải nghiệm người dùng mong muốn

Người dùng mở máy lên sẽ thấy một icon nhỏ nổi trên desktop. Icon này không gây vướng, có thể kéo thả. Khi bấm vào, dashboard hiện ra với nền kính mờ, bo góc, có các card CPU/GPU/RAM/Disk/Temp và một số nút chức năng như:

- Check System
- Clean Cache
- Processes
- Performance Mode
- Settings

## MVP cần đạt

Bản MVP chưa cần hoàn hảo, nhưng cần có:

1. Floating icon.
2. Dashboard glass.
3. Hiển thị CPU/RAM/Disk/Network thật.
4. Hiển thị nhiệt độ nếu hệ thống hỗ trợ.
5. Top processes.
6. Kill process an toàn.
7. Chuyển profile hiệu năng bằng `powerprofilesctl`.
8. Check system bằng các lệnh đọc thông tin.
9. Dọn thumbnail cache an toàn.
10. Tự chạy khi đăng nhập, nếu người dùng bật trong settings.

## Không làm trong MVP

Không làm các chức năng sau ở MVP:

- Không sửa driver.
- Không tự động xóa file hệ thống.
- Không tự động optimize kernel.
- Không chỉnh điện áp CPU/GPU.
- Không tạo service chạy root nền.
- Không chạy lệnh shell tùy ý.
- Không thay thế hoàn toàn System Monitor của KDE.
