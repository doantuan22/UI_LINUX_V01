import QtQuick
import QtQuick.Layouts
import "../styles"
import "../components"

GlassCard {
    id: root

    property string name: "Process"
    property string iconPath: ""
    property string iconName: ""
    property string fallbackGlyph: name.length > 0 ? name.charAt(0).toUpperCase() : "?"
    property string cpuText: "0.0"
    property string ramText: "0 MB"
    property string ramPercentText: "0.0%"
    property bool protectedProcess: false
    property bool killable: !protectedProcess
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
        spacing: 10

        // App icon / fallback
        Item {
            Layout.preferredWidth: Metrics.processIconSize
            Layout.preferredHeight: Metrics.processIconSize
            Layout.alignment: Qt.AlignVCenter

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
                    text: root.fallbackGlyph
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
            verticalAlignment: Text.AlignVCenter
        }

        // CPU
        Text {
            Layout.preferredWidth: Metrics.processCpuWidth
            text: root.cpuText + "%"
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontBody
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Column {
            Layout.preferredWidth: Metrics.processRamWidth
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                width: parent.width
                text: root.ramPercentText
                color: Theme.textPrimary
                font.pixelSize: Metrics.fontBody
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Text {
                width: parent.width
                text: root.ramText
                color: Theme.textMuted
                font.pixelSize: Metrics.fontCaption
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }

        Item {
            Layout.preferredWidth: Metrics.processStatusWidth
            Layout.fillHeight: true

            AppBadge {
                anchors.centerIn: parent
                visible: root.protectedProcess
                text: "Bảo vệ"
                tone: "warning"
            }

            AppBadge {
                anchors.centerIn: parent
                visible: !root.protectedProcess
                text: "Đang chạy"
                tone: "good"
            }
        }

        Item {
            Layout.preferredWidth: Metrics.killButtonWidth
            Layout.fillHeight: true

            SystemActionButton {
                anchors.centerIn: parent
                visible: root.killable
                label: "Kết thúc"
                iconGlyph: "✕"
                width: Metrics.killButtonWidth
                height: 30
                onClicked: root.killRequested(root.pid)
            }
        }
    }
}
