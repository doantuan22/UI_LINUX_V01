# Feature Specs

## 1. Floating Icon

### Mục tiêu

Hiển thị icon nhỏ nổi trên desktop. Khi click sẽ mở hoặc đóng dashboard.

### Yêu cầu

- Luôn nổi trên desktop.
- Có thể kéo thả.
- Có tooltip.
- Có animation hover.
- Không chiếm nhiều tài nguyên.
- Lưu vị trí icon trong config.

### Hành vi

- Click trái: mở/đóng dashboard.
- Kéo: di chuyển icon.
- Click phải: menu nhanh gồm Open, Settings, Quit.

## 2. Dashboard

### Mục tiêu

Hiển thị thông số hệ thống trong panel glass.

### Thông số cần hiển thị

- CPU usage.
- CPU frequency.
- CPU temperature nếu đọc được.
- GPU usage nếu đọc được.
- GPU temperature nếu đọc được.
- RAM usage.
- Disk usage.
- Network download/upload.
- Fan speed nếu đọc được.
- Power profile hiện tại.

### Refresh rate

- Stats cơ bản: 1000ms.
- Process list: 2000ms hoặc refresh thủ công.
- System check: chỉ chạy khi người dùng bấm.

## 3. System Check

### Mục tiêu

Kiểm tra nhanh trạng thái hệ thống bằng các lệnh đọc thông tin an toàn.

### Check mặc định

- Disk usage bằng `df -h`.
- RAM bằng `free -h` hoặc psutil.
- Failed services bằng `systemctl --failed`.
- Critical logs bằng `journalctl -p 3 -xb --no-pager`.
- GPU info bằng `lspci`.

### Output

Trả kết quả dạng summary:

```json
{
  "status": "warning",
  "items": [
    {
      "name": "Failed services",
      "status": "ok",
      "detail": "0 failed services"
    },
    {
      "name": "Critical logs",
      "status": "warning",
      "detail": "2 critical logs found"
    }
  ]
}
```

## 4. Process Manager

### Mục tiêu

Hiển thị tiến trình đang dùng nhiều CPU/RAM và cho phép kill an toàn.

### Yêu cầu

- Chỉ hiển thị process của user hiện tại theo mặc định.
- Sắp xếp theo RAM hoặc CPU.
- Không hiển thị process protected nếu chế độ safe được bật.
- Button Kill cần confirm.
- Không kill process root.
- Không kill process trong protected list.
- Không dùng sudo để kill.

### Kill flow

```text
User click Kill
  ↓
Show confirm dialog
  ↓
Check owner == current user
  ↓
Check not protected
  ↓
Send SIGTERM
  ↓
If still alive, ask for force kill
  ↓
Send SIGKILL only after second confirm
```

## 5. Performance Mode

### Mục tiêu

Chuyển đổi profile hiệu năng Linux.

### Dùng lệnh

```bash
powerprofilesctl get
powerprofilesctl list
powerprofilesctl set power-saver
powerprofilesctl set balanced
powerprofilesctl set performance
```

### Yêu cầu

- Kiểm tra profile nào khả dụng trước khi hiển thị.
- Nếu máy không hỗ trợ `performance`, disable button đó.
- Không giả định profile nào cũng có.
- Trả lỗi thân thiện nếu command không tồn tại.

## 6. Cleanup

### Mục tiêu

Dọn một số cache an toàn.

### Cleanup được phép ở MVP

- Thumbnail cache: `~/.cache/thumbnails`.
- App log riêng của project.
- Có thể hiển thị size cache trước khi xóa.

### Không xóa ở MVP

- Không xóa toàn bộ `~/.cache`.
- Không xóa `/tmp` toàn hệ thống.
- Không chạy `apt autoremove -y`.
- Không chạy `sudo rm -rf`.

## 7. Settings

### Cài đặt cần có

- Autostart.
- Theme: Glass Dark.
- Update interval.
- Show temperature.
- Show network speed.
- Safe mode process kill.
- Floating icon position.
- Start minimized.

## 8. Notification

### Loại notification

- CPU temp cao.
- Disk usage cao.
- RAM usage cao.
- System check có warning.
- Process kill success/fail.

### Yêu cầu

- Không spam notification.
- Có cooldown.
- Cho phép tắt trong settings.
