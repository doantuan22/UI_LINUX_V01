import QtQuick
import QtQuick.Layouts
import "../styles"

RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property color indicatorColor: Theme.info
    property int labelWidth: 66

    width: parent ? parent.width : implicitWidth
    spacing: 8

    Rectangle {
        Layout.preferredWidth: 8
        Layout.preferredHeight: 8
        radius: 4
        color: root.indicatorColor
        Layout.alignment: Qt.AlignTop
        Layout.topMargin: 6
    }

    Text {
        Layout.preferredWidth: root.labelWidth
        text: root.label
        color: Theme.textPrimary
        font.pixelSize: Metrics.fontCaption
        font.weight: Font.DemiBold
        wrapMode: Text.WordWrap
        maximumLineCount: 2
    }

    Text {
        Layout.fillWidth: true
        text: root.value
        color: Theme.textSecondary
        font.pixelSize: Metrics.fontCaption
        wrapMode: Text.WordWrap
        maximumLineCount: 3
        elide: Text.ElideRight
    }
}
