import QtQuick
import "../styles"

Rectangle {
    id: root

    property string text: "Badge"
    property string tone: "info"

    implicitWidth: badgeText.implicitWidth + 18
    implicitHeight: 22
    radius: 11
    color: {
        if (tone === "good") return Qt.rgba(0.20, 0.89, 0.48, 0.16)
        if (tone === "warning") return Qt.rgba(0.98, 0.80, 0.08, 0.16)
        if (tone === "danger") return Qt.rgba(1.0, 0.36, 0.48, 0.16)
        if (tone === "disabled") return Qt.rgba(0.52, 0.57, 0.66, 0.16)
        return Qt.rgba(0.20, 0.78, 1.0, 0.16)
    }
    border.width: 1
    border.color: {
        if (tone === "good") return Qt.rgba(0.20, 0.89, 0.48, 0.45)
        if (tone === "warning") return Qt.rgba(0.98, 0.80, 0.08, 0.45)
        if (tone === "danger") return Qt.rgba(1.0, 0.36, 0.48, 0.45)
        if (tone === "disabled") return Qt.rgba(0.52, 0.57, 0.66, 0.42)
        return Qt.rgba(0.20, 0.78, 1.0, 0.45)
    }

    Text {
        id: badgeText
        anchors.centerIn: parent
        text: root.text
        color: {
            if (tone === "good") return Theme.success
            if (tone === "warning") return Theme.warning
            if (tone === "danger") return Theme.danger
            if (tone === "disabled") return Theme.textMuted
            return Theme.info
        }
        font.pixelSize: 10
        font.weight: Font.DemiBold
        verticalAlignment: Text.AlignVCenter
    }
}
