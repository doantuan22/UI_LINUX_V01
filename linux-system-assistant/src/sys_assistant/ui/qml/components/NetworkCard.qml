import QtQuick
import "../styles"

GlassCard {
    id: root

    property real downloadSpeed: 0
    property real uploadSpeed: 0

    height: 70
    hoverEnabled: true

    Row {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 18

        Column {
            width: parent.width / 2 - 12
            spacing: 4
            Text {
                text: "Tải xuống"
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontCaption
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: root.downloadSpeed.toFixed(1) + " MB/s"
                color: Theme.cpuAccent
                font.pixelSize: Metrics.fontCardValue
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }
        }

        Column {
            width: parent.width / 2 - 12
            spacing: 4
            Text {
                text: "Tải lên"
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontCaption
                elide: Text.ElideRight
                width: parent.width
            }
            Text {
                text: root.uploadSpeed.toFixed(1) + " MB/s"
                color: Theme.gpuAccent
                font.pixelSize: Metrics.fontCardValue
                font.bold: true
                elide: Text.ElideRight
                width: parent.width
            }
        }
    }
}
