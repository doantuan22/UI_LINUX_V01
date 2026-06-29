import QtQuick
import QtQuick.Controls
import "../styles"

Rectangle {
    id: root

    property string text: "Button"
    property string iconText: ""
    property string variant: enabled ? "secondary" : "disabled"
    property bool buttonEnabled: true
    property int preferredHeight: Metrics.buttonHeight

    signal clicked()

    implicitHeight: preferredHeight
    implicitWidth: Math.max(80, label.implicitWidth + (icon.visible ? icon.implicitWidth + 8 : 0) + Metrics.paddingButtonX * 2)
    radius: Metrics.radiusButton
    color: {
        if (!root.enabled || !root.buttonEnabled || root.variant === "disabled") return Qt.rgba(1, 1, 1, 0.08)
        if (root.variant === "primary") return Qt.rgba(0.20, 0.78, 1.0, mouseArea.containsMouse ? 0.30 : 0.24)
        if (root.variant === "danger") return Qt.rgba(1.0, 0.36, 0.48, mouseArea.containsMouse ? 0.26 : 0.20)
        if (root.variant === "ghost") return mouseArea.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
        return mouseArea.containsMouse ? Theme.glassCardHover : Theme.glassCard
    }
    border.width: 1
    border.color: {
        if (!root.enabled || !root.buttonEnabled || root.variant === "disabled") return Qt.rgba(1, 1, 1, 0.12)
        if (root.variant === "primary") return Theme.borderActive
        if (root.variant === "danger") return Qt.rgba(1.0, 0.36, 0.48, 0.55)
        return Theme.borderSoft
    }
    opacity: root.enabled && root.buttonEnabled ? 1.0 : 0.62
    clip: true

    Row {
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: icon
            visible: root.iconText.length > 0
            text: root.iconText
            color: root.variant === "danger" ? Theme.danger : Theme.textPrimary
            font.pixelSize: Metrics.fontBody
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: label
            text: root.text
            color: root.enabled && root.buttonEnabled ? Theme.textPrimary : Theme.textMuted
            font.pixelSize: Metrics.fontBody
            font.weight: root.variant === "primary" ? Font.DemiBold : Font.Medium
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled && root.buttonEnabled
        onClicked: root.clicked()
        onPressed: root.scale = 0.985
        onReleased: root.scale = 1.0
        onCanceled: root.scale = 1.0
    }

    Behavior on color { ColorAnimation { duration: Theme.animFast } }
    Behavior on scale { NumberAnimation { duration: Theme.animFast } }
}
