# System Check Checklist

## Baseline

- [ ] OS/distro/kernel đã ghi.
- [ ] CPU/core/thread đã ghi.
- [ ] RAM/swap đã ghi.
- [ ] Disk/mountpoint đã ghi.
- [ ] GPU/driver đã ghi.
- [ ] Service failed đã kiểm tra.
- [ ] Log critical/error đã kiểm tra.
- [ ] Nhiệt độ/cảm biến đã kiểm tra nếu có.

## Health status

- [ ] CPU không load bất thường.
- [ ] RAM không gần cạn.
- [ ] Swap không bị dùng quá mức.
- [ ] Root partition còn đủ dung lượng.
- [ ] `/tmp` không đầy.
- [ ] Không có lỗi disk I/O.
- [ ] Không có kernel panic/oops nghiêm trọng.
- [ ] Không có service chính bị failed.
- [ ] Không có crash app lặp lại.

## Evidence

- [ ] Mỗi hạng mục có output hoặc log.
- [ ] Có phân loại Good/Warning/Critical/Unknown.
- [ ] Có hành động đề xuất an toàn.
- [ ] Không có lệnh ghi/sửa trái phép.
