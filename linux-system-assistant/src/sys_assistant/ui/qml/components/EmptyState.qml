import QtQuick
import QtQuick.Layouts
import "../styles"

ColumnLayout {
    id: root

    property string title: "Không có dữ liệu"
    property string message: ""
    property string iconText: ""

    spacing: 6

    Text {
        visible: root.iconText.length > 0
        Layout.alignment: Qt.AlignHCenter
        text: root.iconText
        color: Theme.textMuted
        opacity: 0.58
        font.pixelSize: 35
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        Layout.fillWidth: true
        text: root.title
        color: Theme.textPrimary
        font.pixelSize: 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

    Text {
        Layout.fillWidth: true
        visible: root.message.length > 0
        text: root.message
        color: Theme.textSecondary
        font.pixelSize: 12
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }
}
