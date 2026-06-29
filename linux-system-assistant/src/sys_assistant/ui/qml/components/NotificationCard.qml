import QtQuick
import QtQuick.Layouts
import "../styles"

GlassCard {
    id: root

    property string level: "info" // info, warning, danger, success
    property string title: "Notification"
    property string message: "Detail message"
    property string timeText: "Just now"

    property color levelColor: {
        if (level === "warning") return Theme.warning
        if (level === "danger") return Theme.danger
        if (level === "success") return Theme.success
        return Theme.accentBlue
    }

    height: 64
    hoverEnabled: true
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 9

        Rectangle {
            width: 3
            height: parent.height
            color: levelColor
            radius: 2
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: root.title
                    color: Theme.textPrimary
                    font.pixelSize: Metrics.fontBody
                    font.bold: true
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    text: root.timeText
                    color: Theme.textMuted
                    font.pixelSize: 10
                }
            }
            
            Text {
                text: root.message
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontCaption
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                maximumLineCount: 2
            }
        }
    }
}
