import QtQuick
import "../styles"

GlassPanel {
    id: root

    property alias contentItem: content.data
    default property alias content: content.data

    property bool hoverEnabled: true
    property bool selected: false
    property color accentColor: Theme.accentBlue

    radiusSize: Metrics.radiusCard
    color: (hoverEnabled && mouseArea.containsMouse) || selected ? Theme.glassCardHover : Theme.glassCard
    borderColor: selected ? Theme.borderActive : Theme.borderSoft

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: root.hoverEnabled
        acceptedButtons: Qt.NoButton
    }

    Behavior on color {
        ColorAnimation { duration: 150 }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: 10
    }
}
