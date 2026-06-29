# Protocol 01 — Safe System Audit

## Mục tiêu

Kiểm tra tình trạng hệ thống Linux một cách an toàn, không làm thay đổi dữ liệu hoặc cấu hình hệ thống.

## Nguyên tắc

- Chỉ chạy lệnh đọc-only.
- Không dùng `sudo` trừ khi cần đọc log và người dùng đồng ý.
- Không xóa cache, không sửa service, không gỡ package trong giai đoạn audit.
- Mỗi nhóm kiểm tra phải ghi kết quả: `Good`, `Warning`, `Critical`, hoặc `Unknown`.

## Thứ tự kiểm tra

### 1. Thông tin nền

Mục đích: biết môi trường đang chạy.

Lệnh an toàn:

```bash
uname -a
cat /etc/os-release
hostnamectl
uptime
```

Cần ghi:

- Distro.
- Kernel.
- Kiến trúc CPU.
- Thời gian uptime.
- Máy thật/VM nếu nhận biết được.

### 2. CPU/RAM/Load

```bash
lscpu
free -h
vmstat 1 5
uptime
```

Đánh giá:

- RAM còn ít hơn 10%: Warning.
- Swap dùng cao liên tục: Warning.
- Load average lớn hơn số core trong thời gian dài: Warning/Critical.

### 3. Disk và phân vùng

```bash
df -hT
lsblk -o NAME,SIZE,FSTYPE,TYPE,MOUNTPOINTS,MODEL
findmnt
```

Đánh giá:

- `/` dùng dưới 70%: Good.
- `/` dùng 70–84%: Warning.
- `/` dùng 85–94%: High.
- `/` dùng từ 95%: Critical.
- `/tmp` đầy: High/Critical tùy app.

Không được tự ý xóa file. Chỉ được chỉ ra thư mục nghi vấn bằng lệnh đọc-only:

```bash
du -h --max-depth=1 "$HOME" 2>/dev/null | sort -h
```

### 4. Service lỗi

```bash
systemctl --failed --no-pager
systemctl list-units --type=service --state=failed --no-pager
```

Đánh giá:

- Không có failed service: Good.
- Có failed service liên quan app/driver/network: Warning/High.

### 5. Log lỗi nghiêm trọng

```bash
journalctl -p 3 -xb --no-pager -n 200
journalctl -p warning -xb --no-pager -n 200
```

Đánh giá:

- Một vài lỗi cũ, không lặp: Warning nhẹ.
- Lỗi lặp liên tục, crash, segmentation fault: High.
- Lỗi filesystem, disk I/O, kernel panic: Critical.

### 6. GPU/driver

```bash
lspci -k | grep -EA3 'VGA|3D|Display'
glxinfo -B 2>/dev/null || true
vulkaninfo --summary 2>/dev/null || true
```

Đánh giá:

- Có driver kernel đúng: Good.
- Lỗi VAAPI/Nouveau/NVIDIA/AMDGPU lặp lại: Warning/High tùy ảnh hưởng.

### 7. Nhiệt độ/cảm biến

```bash
sensors 2>/dev/null || true
cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null || true
```

Đánh giá tham khảo:

- CPU idle dưới 60°C: Good.
- Idle 60–80°C: Warning.
- Idle trên 80°C: High.
- Trên 90°C kéo dài: Critical.

### 8. Network cơ bản

```bash
ip addr
ip route
resolvectl status 2>/dev/null || systemd-resolve --status 2>/dev/null || true
```

Không ping ngoài internet nếu người dùng không yêu cầu.

## Output bắt buộc

Sau audit, xuất bảng:

| Hạng mục | Trạng thái | Bằng chứng | Nhận xét | Hành động đề xuất |
|---|---|---|---|---|
| CPU | Good/Warning/Critical/Unknown | output ngắn | giải thích | bước tiếp theo |

## Điều kiện dừng

Dừng kiểm tra sâu và báo ngay nếu phát hiện:

- Disk root 95%+.
- RAM gần hết và swap đầy.
- Lỗi disk I/O.
- Kernel panic.
- Service chính của app không khởi động.
- Log crash lặp lại liên tục.
