# TASK 01 - Sửa opacity, contrast và glass theme

## Mục tiêu

Làm panel dễ đọc hơn trên wallpaper phức tạp, không để chữ bị chìm.

## Việc cần làm

1. Mở `Theme.qml`, `Metrics.qml`, `GlassPanel.qml`, `GlassCard.qml`.
2. Tăng opacity panel/card:
   - panel chính khoảng 0.78-0.88.
   - card khoảng 0.08-0.14.
3. Thêm hoặc tăng dim overlay phía sau dashboard nếu có.
4. Tăng contrast chữ:
   - `textPrimary` gần trắng.
   - `textSecondary` sáng hơn.
   - `textMuted` không quá tối.
5. Border panel/card rõ hơn một chút.
6. Shadow/glow nhẹ, không lòe loẹt.

## Không được

- Không làm panel đục 100%.
- Không dùng màu neon quá mạnh cho text thường.
- Không sửa logic hệ thống.

## Acceptance criteria

- Đọc được chữ rõ trên wallpaper sáng/tối.
- Panel vẫn giữ cảm giác glass.
- Card không bị lẫn vào nền.
