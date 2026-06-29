import QtQuick
import "../styles"

GlassCard {
    id: card

    property string title: "CPU"
    property int value: 0
    property int gaugeValue: value
    property string valueText: value + "%"
    property string subValue: ""
    property color accentColor: Theme.cpuAccent
    property bool showProgress: true
    property bool enableThresholdBorder: true

    borderColor: {
        if (enableThresholdBorder && value >= 90) return Theme.danger
        if (enableThresholdBorder && value >= 80) return Theme.warning
        return card.hovered ? card.accentColor : Theme.borderSoft
    }
    border.width: (enableThresholdBorder && value >= 80 || card.hovered) ? 2 : 1

    width: Metrics.statCardSize
    height: Metrics.statCardSize
    hoverEnabled: true

    Column {
        anchors.centerIn: parent
        spacing: 5

        CircularGauge {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 75
            height: 75
            visible: card.showProgress
            value: card.gaugeValue
            valueText: card.valueText
            accentColor: card.accentColor
        }

        Text {
            text: card.title
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontCardLabel
            font.weight: Font.DemiBold
            anchors.horizontalCenter: parent.horizontalCenter
            elide: Text.ElideRight
            width: card.width - 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: card.subValue
            color: Theme.textSecondary
            font.pixelSize: Metrics.fontCardSub
            anchors.horizontalCenter: parent.horizontalCenter
            width: card.width - 16
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
            lineHeight: 0.92
        }
    }
}
