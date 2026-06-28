import QtQuick
import "../styles"

GlassPanel {
    id: root

    property real downloadSpeed: 0
    property real uploadSpeed: 0

    height: 88
    radiusSize: Metrics.cardRadius

    Row {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 24

        Column {
            width: parent.width / 2 - 12
            spacing: 4
            Text {
                text: "Download"
                color: Theme.textSecondary
                font.pixelSize: 12
            }
            Text {
                text: root.downloadSpeed.toFixed(1) + " MB/s"
                color: Theme.cpuAccent
                font.pixelSize: 20
                font.bold: true
            }
        }

        Column {
            width: parent.width / 2 - 12
            spacing: 4
            Text {
                text: "Upload"
                color: Theme.textSecondary
                font.pixelSize: 12
            }
            Text {
                text: root.uploadSpeed.toFixed(1) + " MB/s"
                color: Theme.gpuAccent
                font.pixelSize: 20
                font.bold: true
            }
        }
    }
}
