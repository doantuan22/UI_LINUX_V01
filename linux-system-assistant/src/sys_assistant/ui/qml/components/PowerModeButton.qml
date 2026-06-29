import QtQuick
import "../styles"

GlassCard {
    id: root

    property string label: "Balanced"
    property string profileKey: "balanced"
    property bool active: false
    property bool buttonEnabled: true

    signal clicked()

    height: 34
    hoverEnabled: buttonEnabled
    selected: active
    opacity: buttonEnabled ? 1.0 : 0.65
    clip: true

    Text {
        anchors.centerIn: parent
        width: parent.width - 14
        text: root.label
        color: active ? Theme.textPrimary : Theme.textSecondary
        font.pixelSize: Metrics.fontCaption
        font.weight: active ? Font.DemiBold : Font.Normal
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.buttonEnabled
        onClicked: root.clicked()
    }
}
