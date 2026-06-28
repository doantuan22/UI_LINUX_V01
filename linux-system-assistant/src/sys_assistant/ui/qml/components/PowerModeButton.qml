import QtQuick
import "../styles"

GlassPanel {
    id: root

    property string label: "Balanced"
    property string profileKey: "balanced"
    property bool active: false
    property bool buttonEnabled: true

    signal clicked()

    height: 36
    radiusSize: 12
    color: active ? Qt.rgba(0.2, 0.78, 1, 0.18) : Theme.glassCard
    border.color: active ? Theme.cpuAccent : Theme.border
    opacity: buttonEnabled ? 1.0 : 0.45

    Text {
        anchors.centerIn: parent
        text: root.label
        color: active ? Theme.textPrimary : Theme.textSecondary
        font.pixelSize: 12
        font.weight: active ? Font.DemiBold : Font.Normal
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.buttonEnabled
        onClicked: root.clicked()
    }
}
