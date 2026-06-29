import QtQuick
import "../styles"

GlassCard {
    id: card

    property string title: "CPU"
    property int value: 0
    property string subValue: ""
    property color accentColor: Theme.cpuAccent

    width: Metrics.statCardSize
    height: Metrics.statCardSize
    hoverEnabled: true

    Column {
        anchors.centerIn: parent
        spacing: 6

        CircularGauge {
            anchors.horizontalCenter: parent.horizontalCenter
            value: card.value
            valueText: card.value + "%"
            accentColor: card.accentColor
        }

        Text {
            text: card.title
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontCardLabel
            font.weight: Font.Medium
            anchors.horizontalCenter: parent.horizontalCenter
            elide: Text.ElideRight
            width: card.width - 16
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: card.subValue
            color: Theme.textSecondary
            font.pixelSize: Metrics.fontCardSub
            anchors.horizontalCenter: parent.horizontalCenter
            width: card.width - 16
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
        }
    }
}
