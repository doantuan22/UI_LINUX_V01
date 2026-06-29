import QtQuick
import QtQuick.Shapes
import "../styles"

Item {
    id: root

    property int value: 0
    property string valueText: value + "%"
    property color accentColor: Theme.cpuAccent
    property real lineWidth: 5

    width: 60
    height: 60

    Shape {
        anchors.fill: parent
        ShapePath {
            strokeColor: Qt.rgba(1, 1, 1, 0.08)
            strokeWidth: root.lineWidth
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: root.width / 2
                centerY: root.height / 2
                radiusX: root.width / 2 - root.lineWidth
                radiusY: root.height / 2 - root.lineWidth
                startAngle: 0
                sweepAngle: 360
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
                sweepAngle: 360 * Math.min(Math.max(root.value, 0), 100) / 100
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: root.valueText
        color: Theme.textPrimary
        font.pixelSize: 12
        font.bold: true
    }

    Behavior on value {
        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
    }
}
