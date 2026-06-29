import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../styles"
import "../components"

GlassCard {
    id: root

    property string name: "Process"
    property string iconPath: ""
    property string iconName: ""
    property string fallbackLetter: name.length > 0 ? name.charAt(0).toUpperCase() : "?"
    property string cpuText: "0.0"
    property string ramText: "0.0"
    property bool protectedProcess: false
    property int pid: 0
    property string statusText: protectedProcess ? "Bảo vệ" : "Đang chạy"
    property color statusColor: protectedProcess ? Theme.warning : Theme.success

    signal killRequested(int pid)

    height: Metrics.processRowHeight
    hoverEnabled: true
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 10

        // App icon / fallback
        Item {
            Layout.preferredWidth: Metrics.processIconSize
            Layout.preferredHeight: Metrics.processIconSize

            Image {
                id: processIcon
                anchors.fill: parent
                source: root.iconPath.length > 0 ? "file://" + root.iconPath : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                visible: root.iconPath.length > 0 && status === Image.Ready
            }

            Rectangle {
                anchors.fill: parent
                visible: !processIcon.visible
                radius: width / 2
                color: Theme.glassCard
                border.color: Theme.borderSoft

                Text {
                    anchors.centerIn: parent
                    text: root.fallbackLetter
                    color: Theme.textPrimary
                    font.bold: true
                    font.pixelSize: Metrics.fontBody
                }
            }
        }

        // Name
        Text {
            Layout.fillWidth: true
            text: root.name
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontBody
            elide: Text.ElideRight
        }

        // CPU
        Text {
            Layout.preferredWidth: Metrics.processCpuWidth
            text: root.cpuText + "%"
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontBody
            horizontalAlignment: Text.AlignRight
        }

        // RAM
        Text {
            Layout.preferredWidth: Metrics.processRamWidth
            text: root.ramText + " MB"
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontBody
            horizontalAlignment: Text.AlignRight
        }

        // Status / Kill button
        Item {
            Layout.preferredWidth: Metrics.killButtonWidth
            Layout.fillHeight: true

            Text {
                anchors.centerIn: parent
                visible: root.protectedProcess
                text: "Bảo vệ"
                color: Theme.warning
                font.pixelSize: Metrics.fontCaption
                elide: Text.ElideRight
            }

            SystemActionButton {
                anchors.centerIn: parent
                visible: !root.protectedProcess
                label: "Kết thúc"
                iconGlyph: "✕"
                width: Metrics.killButtonWidth
                height: 30
                onClicked: root.killRequested(root.pid)
            }
        }
    }
}
