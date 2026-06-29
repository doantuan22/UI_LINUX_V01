import QtQuick
import QtQuick.Effects
import "../styles"

Item {
    id: root

    property string iconText: "★"
    property int iconSize: 24
    property color color: Theme.accentBlue
    property bool glowEnabled: true
    
    width: iconSize
    height: iconSize

    Text {
        id: iconDisplay
        anchors.centerIn: parent
        text: root.iconText
        font.pixelSize: root.iconSize
        color: root.color
    }

    MultiEffect {
        source: iconDisplay
        anchors.fill: iconDisplay
        shadowEnabled: root.glowEnabled
        shadowColor: root.color
        shadowBlur: 1.0
        shadowOpacity: 0.8
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 0
    }
}
