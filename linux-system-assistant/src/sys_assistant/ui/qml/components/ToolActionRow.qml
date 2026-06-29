import QtQuick
import QtQuick.Layouts
import "../styles"

GlassCard {
    id: root

    property string title: "Tiêu đề"
    property string subtitle: "Mô tả phụ"
    property string iconText: "★"
    property color accentColor: Theme.accentBlue

    signal clicked()

    height: 56
    hoverEnabled: true
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        GlowIcon {
            iconText: root.iconText
            iconSize: 18
            color: root.accentColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.textPrimary
                font.pixelSize: Metrics.fontBody
                font.bold: true
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontCaption
                elide: Text.ElideRight
            }
        }

        Text {
            text: "›"
            color: Theme.textMuted
            font.pixelSize: 16
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false // Managed by GlassCard
        onClicked: root.clicked()
    }
}
