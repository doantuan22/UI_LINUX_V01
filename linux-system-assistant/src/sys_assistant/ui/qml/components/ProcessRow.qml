import QtQuick
import "../styles"

GlassPanel {
    id: root

    property string processName: ""
    property int pid: 0
    property real cpuPercent: 0
    property real memoryMb: 0

    signal killRequested(int pid)

    height: 44
    radiusSize: 12

    Row {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        Column {
            width: parent.width - 70
            spacing: 2
            Text {
                text: root.processName
                color: Theme.textPrimary
                font.pixelSize: 13
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: "PID " + root.pid + "  •  CPU " + root.cpuPercent.toFixed(1) + "%  •  RAM " + root.memoryMb.toFixed(0) + " MB"
                color: Theme.textMuted
                font.pixelSize: 10
                elide: Text.ElideRight
                width: parent.width
            }
        }

        Rectangle {
            width: 52
            height: 26
            radius: 8
            color: Theme.danger
            opacity: killMouse.containsMouse ? 0.9 : 0.75

            Text {
                anchors.centerIn: parent
                text: "Kill"
                color: "white"
                font.pixelSize: 11
                font.bold: true
            }

            MouseArea {
                id: killMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.killRequested(root.pid)
            }
        }
    }
}
