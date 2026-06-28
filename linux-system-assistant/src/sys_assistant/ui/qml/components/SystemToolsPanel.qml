import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import styles

GlassPanel {
    id: root
    property var bridge
    property var checkPopup
    property var cleanPopup

    property bool checkLoading: false
    property bool cleanLoading: false
    property string lastCheckStatus: ""
    property string lastCleanResult: ""

    radiusSize: Metrics.cardRadius

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        Text {
            text: "System Tools"
            color: Theme.textPrimary
            font.pixelSize: 16
            font.bold: true
            Layout.fillWidth: true
        }

        // System Check
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 10
            color: checkMouseArea.containsMouse ? Theme.glassCardHover : Theme.glassCard
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text { text: "✓"; font.pixelSize: 20; color: Theme.success }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Check System"
                        color: Theme.textPrimary
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        text: checkLoading ? "Checking..." : (lastCheckStatus || "Disk, services, logs, sensors")
                        color: {
                            if (checkLoading) return Theme.cpuAccent
                            if (lastCheckStatus.indexOf("warning") >= 0) return Theme.warning
                            if (lastCheckStatus.indexOf("error") >= 0) return Theme.danger
                            if (lastCheckStatus.indexOf("ok") >= 0) return Theme.success
                            return Theme.textMuted
                        }
                        font.pixelSize: 11
                    }
                }

                Text { text: "›"; font.pixelSize: 18; color: Theme.textMuted }
            }

            MouseArea {
                id: checkMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (bridge && checkPopup && !checkLoading) {
                        checkLoading = true
                        lastCheckStatus = ""
                        var result = bridge.runSystemCheck()
                        checkLoading = false

                        // Format result for display
                        var summary = result.status || "unknown"
                        var items = result.items || []
                        var text = ""
                        for (var i = 0; i < items.length; i++) {
                            var icon = items[i].status === "ok" ? "✅" : (items[i].status === "warning" ? "⚠️" : "❌")
                            text += icon + " " + items[i].name + ": " + (items[i].detail || items[i].status) + "\n"
                        }
                        lastCheckStatus = summary + " (" + items.length + " checks)"
                        checkPopup.text = text || "No data"
                        checkPopup.open()
                    }
                }
            }
        }

        // Clean Cache
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 10
            color: cleanMouseArea.containsMouse ? Theme.glassCardHover : Theme.glassCard
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                Text { text: "🗑"; font.pixelSize: 20; color: Theme.diskAccent }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "Clean Cache"
                        color: Theme.textPrimary
                        font.pixelSize: 13
                        font.bold: true
                    }
                    Text {
                        text: lastCleanResult || "Thumbnail cache cleanup"
                        color: lastCleanResult ? Theme.success : Theme.textMuted
                        font.pixelSize: 11
                    }
                }

                Text { text: "›"; font.pixelSize: 18; color: Theme.textMuted }
            }

            MouseArea {
                id: cleanMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if (cleanPopup) cleanPopup.open()
                }
            }
        }

        // Spacer
        Item { Layout.fillHeight: true }
    }
}
