import QtQuick
import "../styles"

GlassPanel {
    id: root

    property alias contentItem: content.data
    default property alias content: content.data

    radiusSize: Metrics.cardRadius
    color: Theme.glassCard

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onContainsMouseChanged: {
            root.color = containsMouse ? Theme.glassCardHover : Theme.glassCard
        }
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: 12
    }
}
