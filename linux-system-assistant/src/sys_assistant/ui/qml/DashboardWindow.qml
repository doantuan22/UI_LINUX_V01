import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import components
import styles

Window {
    id: dashboard

    property var bridge: sysBridge
    property point anchorPoint: Qt.point(100, 100)
    property bool processesVisible: false
    property bool settingsVisible: false

    width: Metrics.dashboardWidth
    height: Metrics.dashboardHeight
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    visible: false

    x: anchorPoint.x + Metrics.iconSize + 12
    y: Math.max(20, anchorPoint.y - 40)

    property real panelOpacity: 0
    property real panelScale: 0.96

    function openPanel() {
        visible = true
        panelOpacity = 1
        panelScale = 1
        refreshProcesses()
    }

    function closePanel() {
        processesVisible = false
        settingsVisible = false
        panelOpacity = 0
        panelScale = 0.96
        visible = false
    }

    function togglePanel() {
        if (visible) closePanel()
        else openPanel()
    }

    function refreshProcesses() {
        if (processesVisible)
            processList.model = bridge.getTopProcesses()
    }

    Connections {
        target: bridge
        function onStatsUpdated(stats) {
            dashboard.applyStats(stats)
        }
        function onProcessesUpdated(list) {
            processList.model = list
        }
    }

    function applyStats(stats) {
        if (!stats) return
        cpuCard.value = stats.cpu ? Math.round(stats.cpu.usage || 0) : 0
        cpuCard.subValue = stats.cpu && stats.cpu.freq_ghz ? stats.cpu.freq_ghz + " GHz" : "N/A"
        gpuCard.value = stats.gpu && stats.gpu.available ? Math.round(stats.gpu.usage || 0) : 0
        gpuCard.subValue = stats.gpu ? stats.gpu.name : "unavailable"
        ramCard.value = stats.ram ? Math.round(stats.ram.usage || 0) : 0
        ramCard.subValue = stats.ram ? stats.ram.used_gb + " / " + stats.ram.total_gb + " GB" : ""
        diskCard.value = stats.disk ? Math.round(stats.disk.usage || 0) : 0
        diskCard.subValue = stats.disk ? stats.disk.used_gb + " / " + stats.disk.total_gb + " GB" : ""
        tempCard.value = stats.cpu && stats.cpu.temp !== null && stats.cpu.temp !== undefined ? Math.min(Math.round(stats.cpu.temp), 100) : 0
        tempCard.subValue = stats.cpu && stats.cpu.temp !== null && stats.cpu.temp !== undefined ? stats.cpu.temp + " °C" : "N/A"
        fanCard.value = stats.fan && stats.fan.speed_rpm ? Math.min(Math.round(stats.fan.speed_rpm / 50), 100) : 0
        fanCard.subValue = stats.fan && stats.fan.speed_rpm ? stats.fan.speed_rpm + " RPM" : "N/A"
        networkCard.downloadSpeed = stats.network ? stats.network.download_mb_s : 0
        networkCard.uploadSpeed = stats.network ? stats.network.upload_mb_s : 0

        var profile = stats.power_profile || "unknown"
        saverBtn.active = profile.indexOf("power-saver") >= 0 || profile.indexOf("power_saver") >= 0
        balancedBtn.active = profile.indexOf("balanced") >= 0
        perfBtn.active = profile.indexOf("performance") >= 0
    }

    Component.onCompleted: applyStats(bridge.getStats())

    GlassPanel {
        anchors.fill: parent
        radiusSize: Metrics.panelRadius
        opacity: dashboard.panelOpacity
        transform: Scale {
            origin.x: dashboard.width / 2
            origin.y: dashboard.height / 2
            xScale: dashboard.panelScale
            yScale: dashboard.panelScale
        }

        Behavior on opacity { NumberAnimation { duration: 200 } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Metrics.padding
            spacing: Metrics.gap

            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Linux System Assistant"
                    color: Theme.textPrimary
                    font.pixelSize: 18
                    font.bold: true
                    Layout.fillWidth: true
                }
                SystemActionButton {
                    label: "Close"
                    iconGlyph: "✕"
                    Layout.preferredWidth: 90
                    onClicked: dashboard.closePanel()
                }
            }

            Text {
                text: "System Overview"
                color: Theme.textSecondary
                font.pixelSize: 12
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 3
                rowSpacing: Metrics.gap
                columnSpacing: Metrics.gap

                StatCard { id: cpuCard; title: "CPU"; accentColor: Theme.cpuAccent }
                StatCard { id: gpuCard; title: "GPU"; accentColor: Theme.gpuAccent }
                StatCard { id: ramCard; title: "RAM"; accentColor: Theme.ramAccent }
                StatCard { id: diskCard; title: "Disk"; accentColor: Theme.diskAccent }
                StatCard { id: tempCard; title: "Temp"; accentColor: Theme.tempAccent }
                StatCard { id: fanCard; title: "Fan"; accentColor: Theme.fanAccent }
            }

            NetworkCard {
                id: networkCard
                Layout.fillWidth: true
            }

            Text {
                text: "Performance Mode"
                color: Theme.textSecondary
                font.pixelSize: 12
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                PowerModeButton {
                    id: saverBtn
                    Layout.fillWidth: true
                    label: "Power Saver"
                    onClicked: bridge.setPowerProfile("power-saver")
                }
                PowerModeButton {
                    id: balancedBtn
                    Layout.fillWidth: true
                    label: "Balanced"
                    onClicked: bridge.setPowerProfile("balanced")
                }
                PowerModeButton {
                    id: perfBtn
                    Layout.fillWidth: true
                    label: "Performance"
                    onClicked: bridge.setPowerProfile("performance")
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                SystemActionButton {
                    Layout.fillWidth: true
                    label: "Check System"
                    iconGlyph: "✓"
                    onClicked: {
                        var result = bridge.runSystemCheck()
                        checkResultPopup.text = JSON.stringify(result, null, 2)
                        checkResultPopup.open()
                    }
                }
                SystemActionButton {
                    Layout.fillWidth: true
                    label: "Clean Cache"
                    iconGlyph: "🗑"
                    onClicked: cleanCacheDialog.open()
                }
                SystemActionButton {
                    Layout.fillWidth: true
                    label: "Processes"
                    iconGlyph: "☰"
                    onClicked: {
                        processesVisible = !processesVisible
                        settingsVisible = false
                        if (processesVisible) refreshProcesses()
                    }
                }
                SystemActionButton {
                    Layout.fillWidth: true
                    label: "Settings"
                    iconGlyph: "⚙"
                    onClicked: {
                        settingsVisible = !settingsVisible
                        processesVisible = false
                        settingsPanel.loadSettings()
                    }
                }
            }

            GlassPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: processesVisible
                radiusSize: Metrics.cardRadius

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Top Processes"
                            color: Theme.textPrimary
                            font.pixelSize: 14
                            Layout.fillWidth: true
                        }
                        SystemActionButton {
                            label: "Refresh"
                            iconGlyph: "↻"
                            Layout.preferredWidth: 100
                            onClicked: dashboard.refreshProcesses()
                        }
                    }

                    ListView {
                        id: processList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 6
                        delegate: ProcessRow {
                            width: processList.width
                            processName: modelData.name
                            pid: modelData.pid
                            cpuPercent: modelData.cpu
                            memoryMb: modelData.memory_mb
                            onKillRequested: function(pid) {
                                killDialog.pidToKill = pid
                                killDialog.forceKill = false
                                killDialog.open()
                            }
                        }
                    }
                }
            }

            SettingsPanel {
                id: settingsPanel
                Layout.fillWidth: true
                Layout.preferredHeight: settingsVisible ? 180 : 0
                visible: settingsVisible
            }

            Item { Layout.fillHeight: true }
        }
    }

    ConfirmDialog {
        id: killDialog
        property int pidToKill: 0
        property bool forceKill: false
        title: forceKill ? "Force Kill Process?" : "Kill Process?"
        message: forceKill
            ? "Process vẫn còn chạy. Gửi SIGKILL cho PID " + pidToKill + "?"
            : "Gửi SIGTERM tới PID " + pidToKill + "?"
        confirmText: forceKill ? "Force Kill" : "Kill"
        onConfirmed: {
            var result = bridge.killProcess(pidToKill, forceKill)
            statusPopup.text = result.message || JSON.stringify(result)
            statusPopup.open()
            if (!forceKill && bridge.isProcessAlive(pidToKill)) {
                forceKill = true
                Qt.callLater(function() { killDialog.open() })
            } else {
                dashboard.refreshProcesses()
            }
        }
    }

    ConfirmDialog {
        id: cleanCacheDialog
        title: "Clean Thumbnail Cache?"
        message: {
            var info = bridge.getThumbnailCacheSize()
            return "Xóa thumbnail cache (" + (info.human || "0 B") + ")? Chỉ xóa ~/.cache/thumbnails."
        }
        confirmText: "Clean"
        onConfirmed: {
            var result = bridge.cleanThumbnailCache()
            statusPopup.text = result.message || JSON.stringify(result)
            statusPopup.open()
        }
    }

    Popup {
        id: checkResultPopup
        property alias text: resultText.text
        modal: true
        anchors.centerIn: parent
        width: 420
        height: 320
        padding: 0
        background: GlassPanel { radiusSize: Metrics.cardRadius }
        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10
            Text { text: "System Check"; color: Theme.textPrimary; font.bold: true; font.pixelSize: 15 }
            ScrollView {
                width: parent.width
                height: parent.height - 50
                Text {
                    id: resultText
                    color: Theme.textSecondary
                    font.family: "monospace"
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                    width: parent.width
                }
            }
            SystemActionButton {
                anchors.horizontalCenter: parent.horizontalCenter
                label: "Close"
                iconGlyph: "✕"
                onClicked: checkResultPopup.close()
            }
        }
    }

    Popup {
        id: statusPopup
        property alias text: statusText.text
        modal: true
        anchors.centerIn: parent
        width: 360
        padding: 0
        background: GlassPanel { radiusSize: Metrics.cardRadius }
        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            Text { id: statusText; color: Theme.textSecondary; wrapMode: Text.Wrap; width: parent.width }
            SystemActionButton {
                anchors.horizontalCenter: parent.horizontalCenter
                label: "OK"
                iconGlyph: "✓"
                onClicked: statusPopup.close()
            }
        }
    }
}
