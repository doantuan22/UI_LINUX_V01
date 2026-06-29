# 00 - Phân tích vấn đề UI hiện tại

## 1. Glass panel quá trong

Panel hiện tại để wallpaper xuyên qua quá mạnh. Nền anime phía sau có nhiều màu và đường nét, làm text trắng/xám bị chìm.

Cần:
- Tăng opacity panel.
- Có dim overlay phía sau dashboard.
- Card/stat row cũng phải tối hơn một chút.

## 2. Main Monitor Panel còn khoảng trống thừa

Sau khi bỏ các nút shortcut dưới cùng, main panel vẫn cao và bị trống ở phần dưới.

Cần:
- Giảm chiều cao panel.
- Căn lại spacing.
- Giữ nội dung chính: Header, Tổng quan, 6 stat cards, Network, Chế độ hiệu năng.

## 3. Panel dưới cùng bị thấp/chật

Các panel Log lỗi, Thao tác nhanh, Cài đặt bị thấp.

Vấn đề rõ nhất:
- Quick actions bị cắt chữ: `Khởi động ...`, `Khóa màn ...`.
- Settings toggle sát mép.
- Error log text nhỏ và mờ.

Cần:
- Tăng chiều cao panel dưới.
- Chuyển Quick Actions sang grid 2x2 hoặc icon-only + tooltip.
- Custom toggle.

## 4. Process Panel cần nâng cấp

Vấn đề:
- Row hơi thấp.
- Header table sát row.
- Kill button hơi nhỏ.
- Icon process chưa đồng đều.
- Danh sách dài chưa có scrollbar rõ.
- Tên process dài có thể phá layout.

Cần:
- Row height 44-48px.
- Icon 28-32px.
- Kill button 84-96px.
- ListView/ScrollView.
- Process name dùng elide.
- Có fallback icon đẹp.

## 5. Text hierarchy chưa rõ

Một số chữ quá nhỏ:
- Subtitle.
- Tool description.
- Stat subtext.
- Quick action labels.
- Settings labels.

Cần:
- Chuẩn hóa font size.
- Tăng contrast `textSecondary`, `textMuted`.

## 6. Text clipping chưa tốt

Các text bị cắt:
- GPU name.
- Quick action labels.
- Process names dài.

Cần:
- Short display name cho GPU/process.
- Tooltip hoặc elide có chủ đích.
- Label ngắn, không để ellipsis khó hiểu.

## 7. Ngôn ngữ chưa thống nhất

UI đang lẫn tiếng Anh và tiếng Việt:
- `Performance Mode`
- `Download`
- `Upload`
- `Monitor • Optimize • Protect`

Cần ưu tiên tiếng Việt:
- `Chế độ hiệu năng`
- `Tải xuống`
- `Tải lên`
- `Giám sát • Tối ưu • Bảo vệ`

## 8. Toggle setting chưa đồng bộ theme

Toggle hiện tại nhìn giống control mặc định.

Cần:
- Tạo/chuẩn hóa `ToggleSetting.qml`.
- Switch glass/cyan khi bật.
- Row spacing tốt hơn.

## 9. System Tools cần gọn hơn

Chỉ giữ:
- Kiểm tra hệ thống.
- Dọn dẹp hệ thống.
- Thông tin phần cứng.

Không để:
- Quản lý tiến trình.
- Nhật ký hệ thống.

## 10. Floating icon flow

Flow đúng:
- App thu gọn: hiện floating icon.
- Click icon: mở dashboard, ẩn icon.
- Click nút thu gọn trên dashboard: ẩn dashboard, hiện icon lại.
