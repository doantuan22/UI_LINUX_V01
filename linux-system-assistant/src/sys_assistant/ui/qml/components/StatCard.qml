import QtQuick
import "../styles"

GlassPanel {
    id: card

    property string title: "CPU"
    property int value: 0
    property string subValue: ""
    property color accentColor: Theme.cpuAccent

    width: Metrics.statCardSize
    height: Metrics.statCardSize
    radiusSize: Metrics.cardRadius

    Column {
        anchors.centerIn: parent
        spacing: 8

        CircularGauge {
            anchors.horizontalCenter: parent.horizontalCenter
            value: card.value
            valueText: card.value + "%"
            accentColor: card.accentColor
        }

        Text {
            text: card.title
            color: Theme.textPrimary
            font.pixelSize: 15
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: card.subValue
            color: Theme.textSecondary
            font.pixelSize: 11
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
