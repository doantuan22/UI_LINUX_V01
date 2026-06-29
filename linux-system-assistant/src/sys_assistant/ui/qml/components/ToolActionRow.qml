import QtQuick
import QtQuick.Layouts
import "../styles"

GlassCard {
    id: root

    property string title: "Tiêu đề"
    property string subtitle: "Mô tả phụ"
    property string iconText: "★"
    property bool showIcon: true
    property color accentColor: Theme.accentBlue

    signal clicked()

    height: 54
    hoverEnabled: true
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 13
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 12

        GlowIcon {
            visible: root.showIcon
            iconText: root.iconText
            iconSize: 14
            color: root.accentColor
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2
            
            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.textPrimary
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            Text {
                Layout.fillWidth: true
                text: root.subtitle
                color: Theme.textSecondary
                font.pixelSize: 11
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            text: "›"
            color: Theme.textPrimary
            font.pixelSize: 21
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: false // Managed by GlassCard
        onClicked: root.clicked()
    }
}
