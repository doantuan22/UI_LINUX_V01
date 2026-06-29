import QtQuick
import QtQuick.Layouts
import "../styles"

GlassCard {
    id: root

    property real downloadSpeed: 0
    property real uploadSpeed: 0

    property var dlHistory: []
    property var ulHistory: []

    onDownloadSpeedChanged: {
        var temp = dlHistory.slice()
        temp.push(downloadSpeed)
        if (temp.length > 30)
            temp.shift()
        dlHistory = temp
    }

    onUploadSpeedChanged: {
        var temp = ulHistory.slice()
        temp.push(uploadSpeed)
        if (temp.length > 30)
            temp.shift()
        ulHistory = temp
    }

    height: 70
    hoverEnabled: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 14

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: "↓"
                color: Theme.cpuAccent
                font.pixelSize: 24
                Layout.alignment: Qt.AlignVCenter
            }
            ColumnLayout {
                Layout.preferredWidth: 80
                spacing: 1
                Text {
                    text: "Tải xuống"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontCaption
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: root.downloadSpeed.toFixed(1) + " MB/s"
                    color: Theme.cpuAccent
                    font.pixelSize: Metrics.fontCardLabel
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            Sparkline {
                Layout.fillWidth: true
                Layout.fillHeight: true
                values: root.dlHistory
                lineColor: Theme.cpuAccent
            }
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            color: Qt.rgba(0.55, 0.75, 0.88, 0.16)
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 8
            Text {
                text: "↑"
                color: Theme.gpuAccent
                font.pixelSize: 24
                Layout.alignment: Qt.AlignVCenter
            }
            ColumnLayout {
                Layout.preferredWidth: 80
                spacing: 1
                Text {
                    text: "Tải lên"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontCaption
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
                Text {
                    text: root.uploadSpeed.toFixed(1) + " MB/s"
                    color: Theme.gpuAccent
                    font.pixelSize: Metrics.fontCardLabel
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            Sparkline {
                Layout.fillWidth: true
                Layout.fillHeight: true
                values: root.ulHistory
                lineColor: Theme.gpuAccent
            }
        }
    }
}
