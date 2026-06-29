# UI Acceptance Checklist

## Flow
- [ ] App khởi động chỉ hiện floating icon.
- [ ] Click floating icon mở dashboard và ẩn icon.
- [ ] Click `Thu gọn` đóng dashboard và hiện lại icon.
- [ ] Nút `Thoát` không bị nhầm với `Thu gọn`.

## Glass/contrast
- [ ] Panel đủ tối để đọc chữ trên wallpaper phức tạp.
- [ ] Card đủ rõ.
- [ ] Border/shadow/glow đồng nhất.

## Typography/localization
- [ ] Font size dễ đọc.
- [ ] Text phụ không quá mờ.
- [ ] UI ưu tiên tiếng Việt.
- [ ] Không còn label Anh/Việt lẫn lộn không cần thiết.

## Layout/overflow
- [ ] Không panel nào tràn nội dung.
- [ ] Panel dài có scroll.
- [ ] Text dài elide/wrap đúng.
- [ ] Button không vượt khỏi khung.

## Panels
- [ ] Main panel không còn shortcut buttons dưới cùng.
- [ ] Main panel không còn khoảng trống thừa lớn.
- [ ] System Tools chỉ còn 3 chức năng.
- [ ] Process Panel có icon/fallback.
- [ ] Process row không bị cắt.
- [ ] Kill button không chật.
- [ ] Quick Actions không còn chữ `...`.
- [ ] Settings toggle đồng bộ theme.
- [ ] Error/Log panel có empty state rõ.

## Safety
- [ ] Không dùng `shell=True`.
- [ ] Không dùng `os.system`.
- [ ] Không thêm sudo mặc định.
- [ ] Không thêm command ngoài whitelist.
- [ ] Không phá logic kill process an toàn.
