import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../styles"

Popup {
    id: root

    property string title: "Confirm"
    property string message: "Are you sure?"
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"

    signal confirmed()
    signal cancelled()

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    padding: 0

    background: GlassPanel {
        radiusSize: Metrics.cardRadius
        implicitWidth: 320
        implicitHeight: 160
    }

    contentItem: ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 16

        Text {
            text: root.title
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
            Layout.fillWidth: true
        }

        Text {
            text: root.message
            color: Theme.textSecondary
            font.pixelSize: 13
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Item { Layout.fillWidth: true }

            SystemActionButton {
                label: root.cancelText
                iconGlyph: "✕"
                Layout.preferredWidth: 110
                onClicked: {
                    root.cancelled()
                    root.close()
                }
            }

            GlassPanel {
                Layout.preferredWidth: 110
                Layout.preferredHeight: 42
                radiusSize: 12
                color: Theme.danger

                Text {
                    anchors.centerIn: parent
                    text: root.confirmText
                    color: "white"
                    font.pixelSize: 13
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.confirmed()
                        root.close()
                    }
                }
            }
        }
    }
}
