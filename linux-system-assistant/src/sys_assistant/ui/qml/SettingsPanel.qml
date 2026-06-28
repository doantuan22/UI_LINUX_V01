import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import styles

GlassPanel {
    id: root

    radiusSize: Metrics.cardRadius

    function loadSettings() {
        var s = sysBridge.getSettings()
        autostartSwitch.checked = !!s.autostart
        tempSwitch.checked = s.show_temperature !== false
        networkSwitch.checked = s.show_network_speed !== false
        safeModeSwitch.checked = s.safe_mode_process_kill !== false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        Text {
            text: "Settings"
            color: Theme.textPrimary
            font.pixelSize: 14
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Autostart"; color: Theme.textSecondary; Layout.fillWidth: true }
            Switch {
                id: autostartSwitch
                onToggled: sysBridge.updateSetting("autostart", checked)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Show temperature"; color: Theme.textSecondary; Layout.fillWidth: true }
            Switch {
                id: tempSwitch
                onToggled: sysBridge.updateSetting("show_temperature", checked)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Show network speed"; color: Theme.textSecondary; Layout.fillWidth: true }
            Switch {
                id: networkSwitch
                onToggled: sysBridge.updateSetting("show_network_speed", checked)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Text { text: "Safe mode process kill"; color: Theme.textSecondary; Layout.fillWidth: true }
            Switch {
                id: safeModeSwitch
                onToggled: sysBridge.updateSetting("safe_mode_process_kill", checked)
            }
        }
    }
}
