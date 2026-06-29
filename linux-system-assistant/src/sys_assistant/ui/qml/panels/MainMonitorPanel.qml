import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root
    
    property var bridge
    property var stats: ({})
    property string powerProfile: "balanced"
    property bool powerSupported: false
    property var availablePowerProfiles: []
    
    signal focusRequested(string targetPanel)
    signal hideRequested()

    function shortGpuName(name) {
        if (!name || name === "unavailable")
            return "--"
        var cleaned = String(name)
        cleaned = cleaned.replace("NVIDIA GeForce ", "")
        cleaned = cleaned.replace("AMD Radeon ", "Radeon ")
        cleaned = cleaned.replace("Intel(R) ", "Intel ")
        cleaned = cleaned.replace(" Graphics", "")
        return cleaned
    }

    function refreshPowerStatus() {
        if (!bridge)
            return
        var status = bridge.getPowerStatus()
        root.powerSupported = !!status.supported && status.available && status.available.length > 0
        root.availablePowerProfiles = status.available || []
        root.powerProfile = status.current || root.powerProfile || "unknown"
    }

    function hasPowerProfile(profile) {
        if (!root.powerSupported)
            return false
        if (!root.availablePowerProfiles || root.availablePowerProfiles.length === 0)
            return true
        return root.availablePowerProfiles.indexOf(profile) >= 0
    }
    
    // Bind stats updates if bridge is available
    Connections {
        target: bridge
        function onStatsUpdated(newStats) {
            root.stats = newStats;
            root.powerProfile = newStats.powerProfile || newStats.power_profile || "unknown";
        }
        function onActionCompleted(action, result) {
            if (action === "set_power_profile")
                root.refreshPowerStatus()
        }
    }
    
    Component.onCompleted: {
        if (bridge) {
            var initialStats = bridge.getStats();
            root.stats = initialStats;
            root.powerProfile = initialStats.powerProfile || initialStats.power_profile || "unknown";
            root.refreshPowerStatus();
        }
    }

    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.paddingPanel
        spacing: 10

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapSmall
            
            Rectangle {
                Layout.preferredWidth: 42
                Layout.preferredHeight: 42
                radius: 11
                color: Qt.rgba(0.10, 0.42, 0.48, 0.30)
                border.color: Qt.rgba(0.14, 0.93, 0.90, 0.42)
                border.width: 1

                GlowIcon {
                    anchors.centerIn: parent
                    iconText: "⚡"
                    iconSize: 22
                    color: Theme.accentYellow
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "System Assistant"
                    color: Theme.textPrimary
                    font.pixelSize: Metrics.fontAppTitle
                    font.bold: true
                }
                Text {
                    text: "Giám sát • Tối ưu • Bảo vệ"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontCaption
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
            
            RowLayout {
                spacing: 6

                SystemActionButton {
                    label: "Thu gọn"
                    iconGlyph: "▾"
                    Layout.preferredWidth: 88
                    onClicked: root.hideRequested()
                }

                SystemActionButton {
                    label: "Thoát"
                    iconGlyph: "⏻"
                    Layout.preferredWidth: 80
                    onClicked: {
                        if (root.bridge)
                            root.bridge.quitApp()
                    }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Rectangle {
                Layout.preferredWidth: 4
                Layout.preferredHeight: 18
                radius: 2
                color: Theme.accentBlue
            }
            Text {
                text: "Tổng quan hệ thống"
                color: Theme.textPrimary
                font.pixelSize: Metrics.fontSectionTitle
                font.bold: true
            }
        }
        
        // Grid Stats
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: 10
            columnSpacing: 10
            
            StatCard {
                id: cpuCard
                title: "CPU"
                accentColor: Theme.accentBlue
                value: stats.cpu && stats.cpu.usage !== undefined ? Math.round(stats.cpu.usage) : 0
                subValue: stats.cpu && stats.cpu.freq_ghz ? stats.cpu.freq_ghz + " GHz" : "-- GHz"
                Layout.fillWidth: true
                Layout.preferredHeight: 136
            }
            StatCard {
                id: gpuCard
                title: "GPU"
                accentColor: Theme.accentGreen
                value: stats.gpu && stats.gpu.usage !== undefined && stats.gpu.status === "available" ? Math.round(stats.gpu.usage) : 0
                valueText: stats.gpu && stats.gpu.usage !== undefined && stats.gpu.status === "available" ? Math.round(stats.gpu.usage) + "%" : "--"
                subValue: stats.gpu && stats.gpu.name && stats.gpu.name !== "unavailable" ? root.shortGpuName(stats.gpu.name) : "--"
                Layout.fillWidth: true
                Layout.preferredHeight: 136
            }
            StatCard {
                id: ramCard
                title: "RAM"
                accentColor: Theme.accentPurple
                value: stats.ram && stats.ram.usage !== undefined ? Math.round(stats.ram.usage) : 0
                subValue: stats.ram ? stats.ram.used_gb + " / " + stats.ram.total_gb + " GB" : "-- / -- GB"
                Layout.fillWidth: true
                Layout.preferredHeight: 136
            }
            StatCard {
                id: diskCard
                title: "Ổ đĩa"
                accentColor: Theme.accentYellow
                value: stats.disk && stats.disk.usage !== undefined ? Math.round(stats.disk.usage) : 0
                subValue: stats.disk ? stats.disk.used_gb + " / " + stats.disk.total_gb + " GB" : "-- / -- GB"
                Layout.fillWidth: true
                Layout.preferredHeight: 136
            }
            StatCard {
                id: tempCard
                title: "Nhiệt"
                accentColor: Theme.accentRed
                value: stats.cpu && stats.cpu.temp !== null && stats.cpu.temp !== undefined ? Math.min(Math.round(stats.cpu.temp), 100) : 0
                gaugeValue: value
                valueText: stats.cpu && stats.cpu.temp !== null && stats.cpu.temp !== undefined ? Math.round(stats.cpu.temp) + "°C" : "--"
                subValue: "CPU"
                Layout.fillWidth: true
                Layout.preferredHeight: 136
            }
            StatCard {
                id: fanCard
                title: "Quạt"
                accentColor: Theme.accentCyan
                enableThresholdBorder: false
                value: stats.fan && stats.fan.speed_rpm ? stats.fan.speed_rpm : 0
                gaugeValue: stats.fan && stats.fan.speed_rpm ? Math.min(Math.round(stats.fan.speed_rpm / 50), 100) : 0
                valueText: stats.fan && stats.fan.speed_rpm ? Math.round(stats.fan.speed_rpm) + "" : "--"
                subValue: stats.fan && stats.fan.speed_rpm ? "RPM" : "Không có dữ liệu"
                Layout.fillWidth: true
                Layout.preferredHeight: 136
            }
        }
        
        NetworkCard {
            id: networkCard
            Layout.fillWidth: true
            downloadSpeed: stats.network ? stats.network.download_mb_s : 0
            uploadSpeed: stats.network ? stats.network.upload_mb_s : 0
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 2
            spacing: 8
            Text {
                text: "↯"
                color: Theme.accentCyan
                font.pixelSize: 16
            }
            Text {
                text: "Chế độ hiệu năng"
                color: Theme.textPrimary
                font.pixelSize: Metrics.fontSectionTitle
                font.bold: true
            }
        }

        AppBadge {
            visible: !root.powerSupported
            text: "Không khả dụng"
            tone: "disabled"
            Layout.alignment: Qt.AlignHCenter
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapMedium
            
            PowerModeButton {
                id: saverBtn
                Layout.fillWidth: true
                label: "Tiết kiệm pin"
                iconText: "◒"
                buttonEnabled: root.hasPowerProfile("power-saver")
                active: root.powerProfile.indexOf("power-saver") >= 0 || root.powerProfile.indexOf("power_saver") >= 0
                onClicked: { if (bridge) bridge.setPowerProfile("power-saver") }
            }
            PowerModeButton {
                id: balancedBtn
                Layout.fillWidth: true
                label: "Cân bằng"
                iconText: "⚖"
                buttonEnabled: root.hasPowerProfile("balanced")
                active: root.powerProfile.indexOf("balanced") >= 0
                onClicked: { if (bridge) bridge.setPowerProfile("balanced") }
            }
            PowerModeButton {
                id: perfBtn
                Layout.fillWidth: true
                label: "Hiệu năng cao"
                iconText: "◖"
                buttonEnabled: root.hasPowerProfile("performance")
                active: root.powerProfile.indexOf("performance") >= 0
                onClicked: { if (bridge) bridge.setPowerProfile("performance") }
            }
        }
    }
}
