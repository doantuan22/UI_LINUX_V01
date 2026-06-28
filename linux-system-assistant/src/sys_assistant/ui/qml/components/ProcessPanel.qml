import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import styles

GlassPanel {
    id: root
    property var bridge
    property var processModel: []
    property var killDialog
    property string searchText: ""

    radiusSize: Metrics.cardRadius

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "Top Processes"
                color: Theme.textPrimary
                font.pixelSize: 16
                font.bold: true
                Layout.fillWidth: true
            }
            SystemActionButton {
                label: "Refresh"
                iconGlyph: "↻"
                Layout.preferredWidth: 90
                onClicked: {
                    if (bridge) bridge.getTopProcesses()
                }
            }
        }

        // Search bar
        Rectangle {
            Layout.fillWidth: true
            height: 32
            radius: 8
            color: Theme.glassCard
            border.color: Theme.border
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 6
                spacing: 6

                Text {
                    text: "🔍"
                    font.pixelSize: 13
                    color: Theme.textMuted
                }

                TextInput {
                    id: searchInput
                    Layout.fillWidth: true
                    color: Theme.textPrimary
                    font.pixelSize: 12
                    clip: true
                    onTextChanged: root.searchText = text

                    Text {
                        anchors.fill: parent
                        text: "Filter processes..."
                        color: Theme.textMuted
                        font.pixelSize: 12
                        visible: !searchInput.text && !searchInput.activeFocus
                    }
                }
            }
        }

        // Table header
        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            Text { text: "Name"; color: Theme.textMuted; font.pixelSize: 11; Layout.fillWidth: true }
            Text { text: "CPU%"; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
            Text { text: "RAM MB"; color: Theme.textMuted; font.pixelSize: 11; Layout.preferredWidth: 60; horizontalAlignment: Text.AlignRight }
            Item { Layout.preferredWidth: 50 }
        }

        ListView {
            id: processList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: {
                if (!root.processModel) return []
                var filter = root.searchText.toLowerCase()
                if (!filter) return root.processModel
                var filtered = []
                for (var i = 0; i < root.processModel.length; i++) {
                    var item = root.processModel[i]
                    if (item.name.toLowerCase().indexOf(filter) >= 0)
                        filtered.push(item)
                }
                return filtered
            }

            delegate: Rectangle {
                width: processList.width
                height: 36
                radius: 8
                color: mouseArea.containsMouse ? Theme.glassCardHover : Theme.glassCard

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: modelData.name
                            color: Theme.textPrimary
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        // Protected badge
                        Rectangle {
                            visible: modelData.protected || false
                            width: 14
                            height: 14
                            radius: 7
                            color: Theme.warning
                            Text {
                                anchors.centerIn: parent
                                text: "🛡"
                                font.pixelSize: 9
                            }
                        }
                    }

                    Text {
                        text: modelData.cpu.toFixed(1)
                        color: modelData.cpu > 50 ? Theme.danger : Theme.textSecondary
                        font.pixelSize: 12
                        Layout.preferredWidth: 50
                        horizontalAlignment: Text.AlignRight
                    }

                    Text {
                        text: modelData.memory_mb.toFixed(1)
                        color: modelData.memory_mb > 500 ? Theme.warning : Theme.textSecondary
                        font.pixelSize: 12
                        Layout.preferredWidth: 60
                        horizontalAlignment: Text.AlignRight
                    }

                    // Kill button (hidden for protected)
                    SystemActionButton {
                        visible: !(modelData.protected || false)
                        label: "Kill"
                        iconGlyph: "✕"
                        Layout.preferredWidth: 50
                        Layout.preferredHeight: 26
                        onClicked: {
                            if (killDialog) {
                                killDialog.pidToKill = modelData.pid
                                killDialog.forceKill = false
                                killDialog.open()
                            }
                        }
                    }
                    // Placeholder for protected (to keep alignment)
                    Item {
                        visible: modelData.protected || false
                        Layout.preferredWidth: 50
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                }
            }
        }
    }
}
