import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root
    
    property var bridge
    property var processModel: []
    property var killDialog
    clip: true

    Connections {
        target: bridge
        function onProcessesUpdated(list) {
            root.processModel = list
        }
    }

    Component.onCompleted: {
        if (bridge) bridge.getTopProcesses()
        else {
            // Fallback demo data
            root.processModel = [
                { name: "Google Chrome", cpu: 12.5, memory_mb: 850, pid: 1001, protected: false },
                { name: "Visual Studio Code", cpu: 8.2, memory_mb: 620, pid: 1002, protected: false },
                { name: "Discord", cpu: 2.1, memory_mb: 240, pid: 1003, protected: false },
                { name: "systemd", cpu: 0.1, memory_mb: 15, pid: 1, protected: true },
                { name: "Spotify", cpu: 1.5, memory_mb: 180, pid: 1005, protected: false }
            ]
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapSmall

            PanelHeader {
                Layout.fillWidth: true
                title: "Quản lý tiến trình"
                iconText: "☰"
                iconColor: Theme.accentBlue
            }

            SystemActionButton {
                label: "Làm mới"
                iconGlyph: "↻"
                Layout.preferredWidth: 86
                onClicked: {
                    if (bridge) bridge.getTopProcesses()
                }
            }
        }

        // Table Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.preferredWidth: Metrics.processIconSize }
            
            Text {
                Layout.fillWidth: true
                text: "Tiến trình"
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontBody
                elide: Text.ElideRight
            }
            Text {
                Layout.preferredWidth: Metrics.processCpuWidth
                text: "CPU"
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontBody
                horizontalAlignment: Text.AlignRight
            }
            Text {
                Layout.preferredWidth: Metrics.processRamWidth
                text: "RAM"
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontBody
                horizontalAlignment: Text.AlignRight
            }
            Text {
                Layout.preferredWidth: Metrics.killButtonWidth
                text: "Trạng thái"
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontBody
                horizontalAlignment: Text.AlignHCenter
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: root.processModel
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: ProcessRow {
                width: parent.width
                name: modelData.displayName || modelData.name || "Unknown"
                iconPath: modelData.iconPath || ""
                iconName: modelData.iconName || ""
                fallbackLetter: modelData.fallbackLetter || (name.length > 0 ? name.charAt(0).toUpperCase() : "?")
                cpuText: modelData.cpu ? modelData.cpu.toFixed(1) : "0.0"
                ramText: modelData.memory_mb ? modelData.memory_mb.toFixed(0) : "0"
                protectedProcess: modelData.protected || false
                pid: modelData.pid || 0
                
                onKillRequested: function(reqPid) {
                    if (killDialog) {
                        killDialog.pidToKill = reqPid
                        killDialog.forceKill = false
                        killDialog.open()
                    }
                }
            }
        }
    }
}
