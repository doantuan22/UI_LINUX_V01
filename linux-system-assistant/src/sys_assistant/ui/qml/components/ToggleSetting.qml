import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Item {
    id: root

    property string title: "Cài đặt"
    property bool checked: false

    signal toggled(bool checked)

    Layout.fillWidth: true
    height: 38
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.rightMargin: 2
        spacing: 12

        Text {
            text: root.title
            color: root.enabled ? Theme.textPrimary : Theme.textMuted
            font.pixelSize: Metrics.fontBody
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Rectangle {
            id: track
            Layout.preferredWidth: 46
            Layout.preferredHeight: 24
            radius: height / 2
            color: root.checked ? Theme.accentCyan : Theme.glassCard
            border.color: root.checked ? Theme.borderActive : Theme.borderSoft
            border.width: 1
            enabled: root.enabled

            Rectangle {
                id: knob
                width: 18
                height: 18
                radius: 9
                x: root.checked ? parent.width - width - 3 : 3
                y: 3
                color: root.checked ? Theme.textPrimary : Theme.textSecondary

                Behavior on x {
                    NumberAnimation { duration: 140; easing.type: Easing.OutQuad }
                }
            }

            Behavior on color {
                ColorAnimation { duration: 140 }
            }

            MouseArea {
                anchors.fill: parent
                enabled: root.enabled
                onClicked: {
                    root.checked = !root.checked
                    root.toggled(root.checked)
                }
            }
        }
    }
}
