import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import styles

GlassPanel {
    id: root

    radiusSize: Metrics.cardRadius
    clip: true
    property bool suppressAutostart: false

    function loadSettings() {
        var s = sysBridge.getSettings()
        autostartToggle.checked = !!s.autostart
        tempToggle.checked = s.show_temperature !== false
        networkToggle.checked = s.show_network_speed !== false
        safeModeToggle.checked = s.safe_mode_process_kill !== false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: Metrics.gapMedium

        Text {
            text: "Cài đặt"
            color: Theme.textPrimary
            font.pixelSize: Metrics.fontPanelTitle
            font.bold: true
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: Metrics.gapMedium

                ToggleSetting {
                    id: autostartToggle
                    width: parent.width
                    title: "Khởi động cùng hệ thống"
                    onToggled: function(checked) {
                        if (root.suppressAutostart)
                            return
                        if (checked) {
                            root.suppressAutostart = true
                            autostartToggle.checked = false
                            root.suppressAutostart = false
                            autostartConfirm.open()
                        } else {
                            sysBridge.updateSetting("autostart", false)
                        }
                    }
                }

                ToggleSetting {
                    id: tempToggle
                    width: parent.width
                    title: "Hiển thị nhiệt độ"
                    onToggled: function(checked) { sysBridge.updateSetting("show_temperature", checked) }
                }

                ToggleSetting {
                    id: networkToggle
                    width: parent.width
                    title: "Hiển thị tốc độ mạng"
                    onToggled: function(checked) { sysBridge.updateSetting("show_network_speed", checked) }
                }

                ToggleSetting {
                    id: safeModeToggle
                    width: parent.width
                    title: "Chế độ an toàn khi kết thúc tiến trình"
                    onToggled: function(checked) { sysBridge.updateSetting("safe_mode_process_kill", checked) }
                }
            }
        }
    }

    ConfirmDialog {
        id: autostartConfirm
        title: "Xác nhận tự khởi động"
        message: "Cho phép ứng dụng tự khởi động cùng hệ thống?\n(Hệ thống sẽ ghi file vào ~/.config/autostart)"
        onConfirmed: {
            root.suppressAutostart = true
            autostartToggle.checked = true
            root.suppressAutostart = false
            sysBridge.updateSetting("autostart", true)
        }
        onCancelled: {
            root.suppressAutostart = true
            autostartToggle.checked = false
            root.suppressAutostart = false
            sysBridge.updateSetting("autostart", false)
        }
    }
}
