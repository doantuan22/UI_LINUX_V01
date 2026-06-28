# Acceptance Tests

## Test tổng quát

- [ ] App start không crash.
- [ ] Floating icon hiển thị.
- [ ] Click icon mở dashboard.
- [ ] Click lại đóng dashboard.
- [ ] Dashboard có glass style.
- [ ] Stats update định kỳ.
- [ ] App không dùng CPU quá cao khi idle.

## Test monitor

- [ ] CPU usage có số.
- [ ] RAM usage có số.
- [ ] Disk usage có số.
- [ ] Network speed có số.
- [ ] Nếu có sensor, nhiệt độ hiển thị.
- [ ] Nếu không có sensor, UI hiển thị N/A thay vì crash.
- [ ] Nếu không có GPU support, UI hiển thị unavailable thay vì crash.

## Test command safety

- [ ] UI không chứa command raw.
- [ ] Không có `shell=True`.
- [ ] Không có `os.system`.
- [ ] CommandManager từ chối action key không nằm trong whitelist.
- [ ] Command timeout hoạt động.
- [ ] Command lỗi trả message thân thiện.

## Test process manager

- [ ] Top processes hiển thị.
- [ ] Không hiển thị hoặc không cho kill protected process.
- [ ] Không kill process root.
- [ ] Kill cần confirm.
- [ ] SIGTERM chạy trước.
- [ ] SIGKILL chỉ có sau confirm lần hai.

## Test performance mode

- [ ] App detect được `powerprofilesctl` nếu có.
- [ ] Lấy được profile hiện tại nếu hệ thống hỗ trợ.
- [ ] Disable button nếu profile không khả dụng.
- [ ] Báo lỗi thân thiện nếu không có command.

## Test cleanup

- [ ] Tính được size thumbnail cache.
- [ ] Confirm trước khi xóa.
- [ ] Chỉ xóa `~/.cache/thumbnails`.
- [ ] Không xóa `~/.cache` toàn bộ.
- [ ] Không cần sudo.

## Test settings

- [ ] Config tạo tự động nếu chưa có.
- [ ] Lưu vị trí floating icon.
- [ ] Autostart tạo đúng `.desktop`.
- [ ] Tắt autostart xóa hoặc disable đúng file.
