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
    
    // Bind stats updates if bridge is available
    Connections {
        target: bridge
        function onStatsUpdated(newStats) {
            root.stats = newStats;
            root.powerProfile = newStats.powerProfile || newStats.power_profile || "unknown";
        }
    }
    
    Component.onCompleted: {
        if (bridge) {
            var initialStats = bridge.getStats();
            root.stats = initialStats;
            root.powerProfile = initialStats.powerProfile || initialStats.power_profile || "unknown";
        }
    }

    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: Metrics.gapLarge

        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapSmall
            
            // Logo pulse
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                radius: 15
                color: "transparent"
                border.color: Theme.accentPurple
                border.width: 1
                
                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.9; to: 1.05; duration: 2000; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 1.05; to: 0.9; duration: 2000; easing.type: Easing.InOutQuad }
                }
                
                GlowIcon {
                    anchors.centerIn: parent
                    iconText: "⚡"
                    iconSize: 16
                    color: Theme.accentBlue
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
                    Layout.preferredWidth: 76
                    onClicked: root.hideRequested()
                }

                SystemActionButton {
                    label: "Thoát"
                    iconGlyph: "⏻"
                    Layout.preferredWidth: 62
                    onClicked: {
                        if (root.bridge)
                            root.bridge.quitApp()
                    }
                }
            }
        }
        
        Text {
            text: "Tổng quan hệ thống"
            color: Theme.textSecondary
            font.pixelSize: Metrics.fontSectionTitle
            font.bold: true
        }
        
        // Grid Stats
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            rowSpacing: Metrics.gapMedium
            columnSpacing: Metrics.gapMedium
            
            StatCard {
                id: cpuCard
                title: "CPU"
                accentColor: Theme.accentBlue
                value: stats.cpu && stats.cpu.usage !== undefined ? Math.round(stats.cpu.usage) : 0
                subValue: stats.cpu && stats.cpu.freq_ghz ? stats.cpu.freq_ghz + " GHz" : "-- GHz"
                Layout.fillWidth: true
            }
            StatCard {
                id: gpuCard
                title: "GPU"
                accentColor: Theme.accentGreen
                value: stats.gpu && stats.gpu.usage !== undefined && stats.gpu.status === "available" ? Math.round(stats.gpu.usage) : 0
                subValue: stats.gpu && stats.gpu.name && stats.gpu.name !== "unavailable" ? root.shortGpuName(stats.gpu.name) : "--"
                Layout.fillWidth: true
            }
            StatCard {
                id: ramCard
                title: "RAM"
                accentColor: Theme.accentPurple
                value: stats.ram && stats.ram.usage !== undefined ? Math.round(stats.ram.usage) : 0
                subValue: stats.ram ? stats.ram.used_gb + " / " + stats.ram.total_gb + " GB" : "-- / -- GB"
                Layout.fillWidth: true
            }
            StatCard {
                id: diskCard
                title: "Ổ đĩa"
                accentColor: Theme.accentYellow
                value: stats.disk && stats.disk.usage !== undefined ? Math.round(stats.disk.usage) : 0
                subValue: stats.disk ? stats.disk.used_gb + " / " + stats.disk.total_gb + " GB" : "-- / -- GB"
                Layout.fillWidth: true
            }
            StatCard {
                id: tempCard
                title: "Nhiệt"
                accentColor: Theme.accentRed
                value: stats.cpu && stats.cpu.temp !== null && stats.cpu.temp !== undefined ? Math.min(Math.round(stats.cpu.temp), 100) : 0
                subValue: stats.cpu && stats.cpu.temp !== null && stats.cpu.temp !== undefined ? stats.cpu.temp + " °C" : "-- °C"
                Layout.fillWidth: true
            }
            StatCard {
                id: fanCard
                title: "Quạt"
                accentColor: Theme.accentCyan
                value: stats.fan && stats.fan.speed_rpm ? Math.min(Math.round(stats.fan.speed_rpm / 50), 100) : 0
                subValue: stats.fan && stats.fan.speed_rpm ? stats.fan.speed_rpm + " RPM" : "-- RPM"
                Layout.fillWidth: true
            }
        }
        
        NetworkCard {
            id: networkCard
            Layout.fillWidth: true
            downloadSpeed: stats.network ? stats.network.download_mb_s : 0
            uploadSpeed: stats.network ? stats.network.upload_mb_s : 0
        }
        
        Text {
            text: "Chế độ hiệu năng"
            color: Theme.textSecondary
            font.pixelSize: Metrics.fontSectionTitle
            font.bold: true
            Layout.topMargin: Metrics.gapSmall
        }
        
        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapMedium
            
            PowerModeButton {
                id: saverBtn
                Layout.fillWidth: true
                label: "Tiết kiệm pin"
                active: root.powerProfile.indexOf("power-saver") >= 0 || root.powerProfile.indexOf("power_saver") >= 0
                onClicked: { if (bridge) bridge.setPowerProfile("power-saver") }
            }
            PowerModeButton {
                id: balancedBtn
                Layout.fillWidth: true
                label: "Cân bằng"
                active: root.powerProfile.indexOf("balanced") >= 0
                onClicked: { if (bridge) bridge.setPowerProfile("balanced") }
            }
            PowerModeButton {
                id: perfBtn
                Layout.fillWidth: true
                label: "Hiệu năng cao"
                active: root.powerProfile.indexOf("performance") >= 0
                onClicked: { if (bridge) bridge.setPowerProfile("performance") }
            }
        }
    }
}
