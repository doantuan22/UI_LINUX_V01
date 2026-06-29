import QtQuick
import "../styles"

GlassCard {
    id: root

    property string label: "Balanced"
    property string iconText: ""
    property string profileKey: "balanced"
    property bool active: false
    property bool buttonEnabled: true

    signal clicked()

    height: 37
    hoverEnabled: buttonEnabled
    selected: active
    opacity: buttonEnabled ? 1.0 : 0.65
    clip: true

    Row {
        anchors.centerIn: parent
        spacing: 8
        Text {
            visible: root.iconText.length > 0
            text: root.iconText
            color: active ? Theme.accentCyan : Theme.textMuted
            font.pixelSize: 14
        }
        Text {
            width: Math.max(0, root.width - (root.iconText.length > 0 ? 37 : 14))
            text: root.label
            color: active ? Theme.textPrimary : Theme.textSecondary
            font.pixelSize: Metrics.fontBody
            font.weight: active ? Font.DemiBold : Font.Normal
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.buttonEnabled
        onClicked: root.clicked()
    }
}
