import QtQuick
import QtQuick.Shapes
import "../styles"

Item {
    id: root

    property real value: 0
    property string valueText: value + "%"
    property color accentColor: Theme.cpuAccent
    property real lineWidth: 7
    property real clampedValue: Math.min(Math.max(value, 0), 100)

    width: 75
    height: 75
    layer.enabled: true
    layer.samples: 4

    Shape {
        anchors.fill: parent
        antialiasing: true
        ShapePath {
            strokeColor: Qt.rgba(1, 1, 1, 0.11)
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.lineWidth
                radiusY: root.height / 2 - root.lineWidth
                startAngle: -90
                sweepAngle: 359.9
            }
        }
        ShapePath {
            strokeColor: root.accentColor
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.lineWidth
                radiusY: root.height / 2 - root.lineWidth
                startAngle: -90
                sweepAngle: 359.9 * root.clampedValue / 100
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.valueText
        color: Theme.textPrimary
        font.pixelSize: 19
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Behavior on value {
        NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic }
    }
}
