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
                property bool suppressToggle: false
                
                onToggled: {
                    if (suppressToggle) return;
                    
                    if (checked) {
                        suppressToggle = true;
                        checked = false; // revert temporarily
                        suppressToggle = false;
                        autostartConfirm.open();
                    } else {
                        sysBridge.updateSetting("autostart", false);
                    }
                }
            }
        }

    components.ConfirmDialog {
        id: autostartConfirm
        title: "Xác nhận Autostart"
        message: "Cho phép ứng dụng tự khởi động cùng hệ thống?\n(Hệ thống sẽ ghi file vào ~/.config/autostart)"
        onConfirmed: {
            autostartSwitch.suppressToggle = true;
            autostartSwitch.checked = true;
            autostartSwitch.suppressToggle = false;
            sysBridge.updateSetting("autostart", true);
        }
        onCancelled: {
            autostartSwitch.suppressToggle = true;
            autostartSwitch.checked = false;
            autostartSwitch.suppressToggle = false;
            sysBridge.updateSetting("autostart", false);
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
