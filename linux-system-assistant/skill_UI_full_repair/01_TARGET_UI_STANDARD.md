# 01 - Tiêu chuẩn UI mục tiêu

## Mục tiêu cảm giác thị giác

UI phải giống một desktop glass control center:
- Tối, trong vừa phải, không quá xuyên nền.
- Các panel nổi rõ trên wallpaper.
- Chữ đọc rõ ở mọi wallpaper.
- Layout cân bằng, không bị chật.
- Không có nội dung tràn.
- Không có text bị `...` nếu không cần thiết.

## Design tokens khuyến nghị

```qml
property color overlayDim: Qt.rgba(0.0, 0.0, 0.0, 0.28)

property color glassPanel: Qt.rgba(0.05, 0.10, 0.17, 0.82)
property color glassPanelStrong: Qt.rgba(0.04, 0.08, 0.14, 0.88)
property color glassCard: Qt.rgba(1, 1, 1, 0.10)
property color glassCardHover: Qt.rgba(1, 1, 1, 0.15)

property color borderSoft: Qt.rgba(1, 1, 1, 0.16)
property color borderActive: Qt.rgba(0.20, 0.75, 1.00, 0.65)

property color textPrimary: "#F5F9FF"
property color textSecondary: "#B8C4D6"
property color textMuted: "#8D9AAF"

property color accentBlue: "#35C7FF"
property color accentGreen: "#35E27A"
property color accentPurple: "#A855F7"
property color accentYellow: "#FACC15"
property color accentRed: "#FB7185"
property color accentCyan: "#22D3EE"
```

## Font size khuyến nghị

```text
App title:          16-18px bold
Panel title:        15-17px bold
Section title:      13-14px semibold
Card value:         18-22px
Card label:         13-14px
Card sub text:      11-12px
Tool title:         13-14px semibold
Tool subtitle:      11-12px
Table text:         12-13px
Button text:        12-13px
```

## Kích thước panel gợi ý

Điều chỉnh theo màn hình thực tế, nhưng tránh quá thấp:

```text
MainMonitorPanel:    430-470w x 560-610h
SystemToolsPanel:    430-470w x 270-310h
ProcessPanel:        430-470w x 310-360h
ErrorLogPanel:       250-300w x 150-180h
QuickActionsPanel:   360-420w x 160-200h
SettingsPanel:       260-320w x 150-190h
```

## Quy tắc ngôn ngữ

Ưu tiên tiếng Việt:
- `Performance Mode` -> `Chế độ hiệu năng`
- `Download` -> `Tải xuống`
- `Upload` -> `Tải lên`
- `Monitor • Optimize • Protect` -> `Giám sát • Tối ưu • Bảo vệ`
- `System Assistant` có thể giữ nguyên hoặc đổi thành `Trợ lý hệ thống`.

Không trộn tiếng Anh/Việt trong cùng một section trừ khi là tên app hoặc tên process.
