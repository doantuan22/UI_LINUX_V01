# Safety Rules

## Nguyên tắc tuyệt đối

Project này có khả năng thao tác với hệ thống Linux, vì vậy phải tuân thủ nghiêm ngặt các quy tắc an toàn sau.

## 1. Không chạy command tự do

Cấm:

```python
os.system(user_input)
subprocess.run(user_input, shell=True)
subprocess.Popen(user_input, shell=True)
```

Được phép:

```python
subprocess.run(["df", "-h"], shell=False)
```

Chỉ được chạy command thông qua `CommandManager`.

## 2. Tất cả command phải nằm trong whitelist

UI chỉ được gửi action key, ví dụ:

```text
check_disk
check_failed_services
balanced
clean_thumbnail_cache
```

Không được gửi command raw như:

```text
rm -rf ~/.cache
sudo apt clean
```

## 3. Không dùng sudo mặc định

MVP ưu tiên không dùng sudo.

Nếu một action cần quyền cao:

- Phải được đánh dấu rõ trong config.
- Phải dùng `pkexec` hoặc Polkit thay vì tự xử lý mật khẩu.
- Phải có confirm rõ ràng.
- Không lưu mật khẩu.
- Không truyền mật khẩu qua stdin.

## 4. Cấm lệnh nguy hiểm

Không thêm các lệnh sau vào project:

```bash
rm -rf /
rm -rf *
sudo rm -rf
mkfs
dd
chmod -R 777 /
chown -R
kill -9 -1
pkill
killall
systemctl disable
systemctl stop
apt autoremove -y
apt purge -y
```

## 5. Quy tắc kill process

Chỉ được kill process khi thỏa tất cả điều kiện:

- PID hợp lệ.
- Process thuộc user hiện tại.
- Process không chạy dưới root.
- Process không nằm trong protected list.
- Người dùng đã confirm.
- Dùng SIGTERM trước.
- Dùng SIGKILL chỉ sau confirm lần hai.

Không được:

- Kill process theo tên bằng `pkill`.
- Kill toàn bộ group process nếu chưa phân tích.
- Kill process hệ thống.
- Dùng sudo kill.
- Kill chính app hiện tại mà không cảnh báo.

## 6. Quy tắc xóa file

Chỉ xóa trong đường dẫn đã hard-code và thuộc home của user.

Được phép:

```text
~/.cache/thumbnails/*
```

Không được phép:

```text
/
~/
~/.cache/*
/tmp/*
/var/*
/usr/*
```

Trước khi xóa, nên:

- Resolve path.
- Kiểm tra path nằm trong home.
- Kiểm tra path có đúng folder dự kiến.
- Hiển thị dung lượng sẽ xóa nếu có thể.

## 7. Quy tắc system check

Các lệnh system check ở MVP chỉ nên đọc thông tin:

```bash
df -h
free -h
uptime
sensors
systemctl --failed
journalctl -p 3 -xb --no-pager
lspci
lsblk
```

Không được tự sửa lỗi.

## 8. Logging

Mọi action có thay đổi hệ thống cần ghi log:

- Timestamp.
- Action key.
- Result.
- Error nếu có.
- Không ghi thông tin nhạy cảm như mật khẩu.

## 9. UI confirmation

Các action cần confirm:

- Kill process.
- Force kill process.
- Clean cache.
- Enable autostart.
- Any action requiring elevated permission.

## 10. Fail safe

Nếu không chắc một action có an toàn không, không thực hiện action đó. Trả về thông báo rõ:

```text
Action này chưa được hỗ trợ vì cần policy an toàn rõ ràng hơn.
```
