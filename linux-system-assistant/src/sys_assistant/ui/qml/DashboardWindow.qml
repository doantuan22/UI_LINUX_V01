import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import components
import "panels"
import styles

Window {
    id: dashboard

    property var bridge: sysBridge
    property point anchorPoint: Qt.point(100, 100)
    
    // UI state
    property string activePanel: "tools" // "tools", "processes", "settings"

    width: Metrics.dashboardWidth
    height: Metrics.dashboardHeight
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    x: anchorPoint.x + Metrics.iconSize + 12
    y: Math.max(20, anchorPoint.y - 40)

    property real panelOpacity: 0
    property real panelScale: 0.96

    function openPanel() {
        visible = true
        show()
        raise()
        requestActivate()
        panelOpacity = 1
        panelScale = 1
        if (activePanel === "processes") refreshProcesses()
    }

    function closePanel() {
        panelOpacity = 0
        panelScale = 0.96
        visible = false
    }

    function togglePanel() {
        if (visible) closePanel()
        else openPanel()
    }

    function refreshProcesses() {
        if (activePanel === "processes")
            bridge.requestTopProcesses()
    }

    Connections {
        target: bridge
        function onStatsUpdated(stats) {
            dashboard.applyStats(stats)
        }
        function onProcessesUpdated(list) {
            processPanelComponent.processModel = list
        }
    }

    function applyStats(stats) {
        if (!stats) return
        cpuCard.value = stats.cpu ? Math.round(stats.cpu.usage || 0) : 0
        cpuCard.subValue = stats.cpu && stats.cpu.freq_ghz ? stats.cpu.freq_ghz + " GHz" : "N/A"

        // GPU: distinguish available / unsupported / unavailable
        var gpuStatus = stats.gpu ? (stats.gpu.status || "unavailable") : "unavailable"
        if (gpuStatus === "available") {
            gpuCard.value = Math.round(stats.gpu.usage || 0)
            gpuCard.subValue = stats.gpu.name
        } else if (gpuStatus === "unsupported") {
            gpuCard.value = 0
            gpuCard.subValue = stats.gpu.name + " (unsupported)"
        } else {
            gpuCard.value = 0
            gpuCard.subValue = "unavailable"
        }

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

        RowLayout {
            anchors.fill: parent
            anchors.margins: Metrics.padding
            spacing: Metrics.gap

            // Left Side: Main Monitor
            ColumnLayout {
                Layout.minimumWidth: 480
                Layout.maximumWidth: 480
                Layout.preferredWidth: 480
                Layout.fillHeight: true
                spacing: Metrics.gap

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: "⚡"
                        font.pixelSize: 28
                        color: Theme.cpuAccent
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: "System Assistant"
                            color: Theme.textPrimary
                            font.pixelSize: 20
                            font.bold: true
                        }
                        Text {
                            text: "Giám sát • Tối ưu • Bảo vệ"
                            color: Theme.textSecondary
                            font.pixelSize: 12
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                        spacing: 8
                        
                        SystemActionButton {
                            label: "Thu gọn"
                            iconGlyph: "✕"
                            Layout.preferredWidth: 80
                            onClicked: dashboard.closePanel()
                        }
                        
                        SystemActionButton {
                            label: "Thoát"
                            iconGlyph: "⏻"
                            Layout.preferredWidth: 80
                            onClicked: {
                                if (sysBridge && sysBridge.quitApp)
                                    sysBridge.quitApp()
                                else
                                    Qt.quit()
                            }
                        }
                    }
                }

                // Grid Stats
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
                    StatCard { id: fanCard; title: "Fan"; accentColor: Theme.fanAccent; enableThresholdBorder: false }
                }

                NetworkCard {
                    id: networkCard
                    Layout.fillWidth: true
                }

                // Power Profiles
                Text {
                    text: "Chế độ hiệu năng"
                    color: Theme.textSecondary
                    font.pixelSize: 12
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    PowerModeButton {
                        id: saverBtn
                        Layout.fillWidth: true
                        label: "Tiết kiệm pin"
                        onClicked: bridge.setPowerProfile("power-saver")
                    }
                    PowerModeButton {
                        id: balancedBtn
                        Layout.fillWidth: true
                        label: "Cân bằng"
                        onClicked: bridge.setPowerProfile("balanced")
                    }
                    PowerModeButton {
                        id: perfBtn
                        Layout.fillWidth: true
                        label: "Hiệu năng cao"
                        onClicked: bridge.setPowerProfile("performance")
                    }
                }

                Item { Layout.fillHeight: true } // spacer
            }

            // Right Side: Sidebar Tools
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Metrics.gap

                // Tab selectors
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    
                    SystemActionButton {
                        Layout.fillWidth: true
                        label: "Công cụ"
                        iconGlyph: "🔧"
                        opacity: activePanel === "tools" ? 1.0 : 0.6
                        onClicked: activePanel = "tools"
                    }
                    SystemActionButton {
                        Layout.fillWidth: true
                        label: "Tiến trình"
                        iconGlyph: "☰"
                        opacity: activePanel === "processes" ? 1.0 : 0.6
                        onClicked: {
                            activePanel = "processes"
                            refreshProcesses()
                        }
                    }
                    SystemActionButton {
                        Layout.fillWidth: true
                        label: "Cài đặt"
                        iconGlyph: "⚙"
                        opacity: activePanel === "settings" ? 1.0 : 0.6
                        onClicked: activePanel = "settings"
                    }
                }

                // StackView equivalent using simple visibility
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    SystemToolsPanel {
                        id: toolsPanelComponent
                        anchors.fill: parent
                        visible: activePanel === "tools"
                        bridge: sysBridge
                    }

                    ProcessPanel {
                        id: processPanelComponent
                        anchors.fill: parent
                        visible: activePanel === "processes"
                        bridge: sysBridge
                        killDialog: killDialog
                        autoRefreshEnabled: dashboard.visible && activePanel === "processes"
                    }

                    SettingsPanel {
                        id: settingsPanelComponent
                        anchors.fill: parent
                        visible: activePanel === "settings"
                        onVisibleChanged: {
                            if (visible) loadSettings()
                        }
                    }
                }
            }
        }
    }

    ConfirmDialog {
        id: killDialog
        property int pidToKill: 0
        property bool forceKill: false
        title: forceKill ? "Buộc kết thúc tiến trình?" : "Kết thúc tiến trình?"
        message: forceKill
            ? "Process vẫn còn chạy. Gửi SIGKILL cho PID " + pidToKill + "?"
            : "Gửi SIGTERM tới PID " + pidToKill + "?"
        confirmText: forceKill ? "Buộc kết thúc" : "Kết thúc"
        onConfirmed: {
            var result = bridge.killProcess(pidToKill, forceKill)
            statusPopup.text = result.message || JSON.stringify(result)
            statusPopup.open()
            if (!forceKill) {
                // Đợi 1.5 giây để tiến trình có thời gian tự thoát trước khi kiểm tra lại
                gracePeriodTimer.pidToCheck = pidToKill
                gracePeriodTimer.start()
            } else {
                dashboard.refreshProcesses()
            }
        }
    }

    Timer {
        id: gracePeriodTimer
        property int pidToCheck: 0
        interval: 1500
        repeat: false
        onTriggered: {
            if (bridge.isProcessAlive(pidToCheck)) {
                killDialog.forceKill = true
                killDialog.pidToKill = pidToCheck
                killDialog.open()
            } else {
                dashboard.refreshProcesses()
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
