import QtQuick
import QtQuick.Effects
import "../styles"

Rectangle {
    id: root

    property bool active: false
    property real radiusSize: Metrics.radiusPanel
    property color glassColor: Theme.glassPanel
    property color borderColor: active ? Theme.borderActive : Theme.borderSoft

    color: glassColor
    radius: radiusSize
    border.width: 1
    border.color: borderColor
    clip: true

    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.55
        shadowOpacity: 0.36
        shadowVerticalOffset: 10
    }
}
