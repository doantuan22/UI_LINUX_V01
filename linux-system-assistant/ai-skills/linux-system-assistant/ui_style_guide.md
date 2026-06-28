# UI Glass Style Guide

## Phong cách

UI theo phong cách:

- Glassmorphism.
- Dark mode.
- Translucent card.
- Bo góc lớn.
- Viền trắng mờ.
- Glow nhẹ.
- Icon neon.
- Animation mượt nhưng không quá nặng.

## Layout tổng thể

```text
Floating Icon
  ↓ click
Dashboard Window
  ├── Header
  ├── Overview Stat Grid
  ├── Network Card
  ├── Performance Mode
  ├── Bottom Action Bar
  └── Optional panels:
      ├── Process Manager
      ├── System Tools
      ├── Notifications
      └── Settings
```

## Màu sắc đề xuất

```text
Background:      #050B14
Glass panel:     rgba(18, 28, 45, 0.62)
Card:            rgba(255, 255, 255, 0.06)
Card hover:      rgba(255, 255, 255, 0.10)
Border:          rgba(255, 255, 255, 0.12)
Text primary:    #FFFFFF
Text secondary:  #AEB9C8
Text muted:      #718096

CPU accent:      #35C7FF
GPU accent:      #35E27A
RAM accent:      #A855F7
Disk accent:     #FACC15
Temp accent:     #FB7185
Fan accent:      #22D3EE
Danger:          #FF5C7A
Warning:         #FACC15
Success:         #35E27A
```

## Kích thước gợi ý

```text
Floating icon:       56 x 56
Dashboard width:     520 - 620
Dashboard height:    700 - 820
Card radius:         18 - 24
Small card:          150 x 150
Main panel radius:   24
Padding:             16 - 24
Gap:                 12 - 16
```

## Component bắt buộc

### GlassPanel.qml

Dùng cho khung chính.

Yêu cầu:

- Radius lớn.
- Nền trong suốt.
- Border sáng nhẹ.
- Shadow mềm.
- Có thể tái sử dụng.

### GlassCard.qml

Dùng cho card con.

Yêu cầu:

- Nhẹ hơn GlassPanel.
- Hover effect.
- Có slot content.

### StatCard.qml

Dùng cho CPU/GPU/RAM/Disk/Temp/Fan.

Nội dung:

- CircularGauge.
- Value chính.
- Label.
- Sub value.

### CircularGauge.qml

Dùng vẽ vòng tròn phần trăm.

Yêu cầu:

- Nhận `value` từ 0 đến 100.
- Nhận `accentColor`.
- Có text giữa vòng.
- Không dùng ảnh tĩnh.

### NetworkCard.qml

Hiển thị:

- Download speed.
- Upload speed.
- Sparkline optional.

### PowerModeButton.qml

Hiển thị 3 mode:

- Power Saver
- Balanced
- Performance

Mode đang chọn có border/glow accent.

### ProcessRow.qml

Hiển thị:

- Icon app optional.
- Process name.
- CPU %.
- RAM MB/GB.
- Button Kill.

Button Kill phải dùng màu danger và cần confirm.

### SystemActionButton.qml

Dùng cho:

- Check System
- Clean Cache
- Processes
- Settings

## Animation

Nên có:

- Fade in dashboard.
- Scale nhẹ khi mở.
- Hover tăng opacity.
- Button press scale 0.98.
- Gauge transition khi value đổi.

Không nên:

- Animation quá nhiều.
- Blur quá nặng gây lag.
- Particle effect.
- Hiệu ứng làm tăng CPU khi app monitor đang chạy.

## QML component mẫu: GlassPanel

```qml
import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: root

    property real radiusSize: 22
    property color glassColor: Qt.rgba(0.08, 0.12, 0.18, 0.62)
    property color borderColor: Qt.rgba(1, 1, 1, 0.12)

    color: glassColor
    radius: radiusSize
    border.width: 1
    border.color: borderColor

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.8
        shadowOpacity: 0.35
        shadowVerticalOffset: 8
    }
}
```

## QML component mẫu: StatCard

```qml
import QtQuick
import QtQuick.Controls

GlassPanel {
    id: card

    property string title: "CPU"
    property int value: 18
    property string subValue: "3.2 GHz"
    property color accentColor: "#35C7FF"

    width: 150
    height: 150

    Column {
        anchors.centerIn: parent
        spacing: 8

        CircularGauge {
            width: 76
            height: 76
            value: card.value
            valueText: card.value + "%"
            accentColor: card.accentColor
        }

        Text {
            text: card.title
            color: "white"
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: card.subValue
            color: "#AEB9C8"
            font.pixelSize: 12
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
```
