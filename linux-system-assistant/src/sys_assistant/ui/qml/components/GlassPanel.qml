import QtQuick
import QtQuick.Effects
import "../styles"

Rectangle {
    id: root

    property real radiusSize: Metrics.panelRadius
    property color glassColor: Theme.glassPanel
    property color borderColor: Theme.border

    color: glassColor
    radius: radiusSize
    border.width: 1
    border.color: borderColor

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.8
        shadowOpacity: 0.35
        shadowVerticalOffset: 8
    }
}
