import QtQuick
import "../styles"

GlassPanel {
    id: root

    property string label: "Action"
    property string iconGlyph: "⚙"

    signal clicked()

    height: 42
    radiusSize: 12

    Row {
        anchors.centerIn: parent
        spacing: 8
        Text {
            text: root.iconGlyph
            color: Theme.textPrimary
            font.pixelSize: 14
        }
        Text {
            text: root.label
            color: Theme.textPrimary
            font.pixelSize: 13
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        onPressed: root.scale = 0.98
        onReleased: root.scale = 1.0
    }

    Behavior on scale { NumberAnimation { duration: 100 } }
}
