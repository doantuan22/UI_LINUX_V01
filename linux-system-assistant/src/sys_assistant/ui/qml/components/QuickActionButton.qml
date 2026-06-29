import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

GlassCard {
    id: root

    property string title: "Nút"
    property string iconText: "★"
    property color accentColor: Theme.accentBlue
    property bool buttonEnabled: false

    signal clicked()

    width: 156
    height: Metrics.quickActionMinHeight
    hoverEnabled: buttonEnabled
    opacity: buttonEnabled ? 1.0 : 0.62
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        GlowIcon {
            Layout.alignment: Qt.AlignHCenter
            iconText: root.iconText
            iconSize: 18
            color: root.accentColor
            glowEnabled: root.buttonEnabled
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            text: root.title
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontCaption
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: false // Managed by GlassCard
        enabled: root.buttonEnabled
        onClicked: root.clicked()
    }

    ToolTip.visible: mouseArea.containsMouse && !root.buttonEnabled
    ToolTip.text: root.title
    ToolTip.delay: 500
}
