import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

GlassCard {
    id: root

    property string title: "Nút"
    property string iconText: "★"
    property string subtitle: ""
    property string badgeText: ""
    property color accentColor: Theme.accentBlue
    property bool buttonEnabled: false

    signal clicked()

    width: 156
    height: 117
    hoverEnabled: buttonEnabled
    opacity: buttonEnabled ? 1.0 : 0.82
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 11
        spacing: 6

        GlowIcon {
            Layout.alignment: Qt.AlignHCenter
            iconText: root.iconText
            iconSize: 27
            color: root.accentColor
            glowEnabled: root.buttonEnabled
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            text: root.title
            color: Theme.textPrimary
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }

        Text {
            visible: root.subtitle.length > 0
            Layout.fillWidth: true
            text: root.subtitle
            color: Theme.textMuted
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
        }

        AppBadge {
            visible: root.badgeText.length > 0
            Layout.alignment: Qt.AlignHCenter
            text: root.badgeText
            tone: root.buttonEnabled ? "info" : "disabled"
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
    ToolTip.text: root.subtitle.length > 0 ? root.subtitle : root.title
    ToolTip.delay: 500
}
