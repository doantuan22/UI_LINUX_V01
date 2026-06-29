import QtQuick
import "../styles"

GlassCard {
    id: root

    property string label: "Action"
    property string iconGlyph: "⚙"

    signal clicked()

    height: Metrics.buttonHeight
    hoverEnabled: true
    clip: true

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        Text {
            text: root.iconGlyph
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontBody
        }
        Text {
            width: Math.max(0, root.width - 26)
            text: root.label
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontBody
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false // Managed by GlassCard
        onClicked: root.clicked()
        onPressed: root.scale = 0.98
        onReleased: root.scale = 1.0
    }

    Behavior on scale { NumberAnimation { duration: 100 } }
}
