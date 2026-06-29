import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root
    
    property var bridge
    clip: true

    function loadSettings() {
        if (bridge) {
            var s = bridge.getSettings()
            autostartToggle.checked = !!s.autostart
            tempToggle.checked = s.show_temperature !== false
            autoHideToggle.checked = !!s.auto_hide
        }
    }

    Component.onCompleted: loadSettings()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 12
        
        PanelHeader {
            title: "Cài đặt"
            iconText: "⚙"
            iconColor: Theme.textSecondary
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            Column {
                width: parent.width
                spacing: 10

                ToggleSetting {
                    id: autostartToggle
                    width: parent.width
                    title: "Khởi động cùng hệ thống"
                    onToggled: function(checked) {
                        if (bridge) bridge.updateSetting("autostart", checked)
                    }
                }

                ToggleSetting {
                    id: autoHideToggle
                    width: parent.width
                    title: "Tự động thu gọn"
                    onToggled: function(checked) {
                        if (bridge) bridge.updateSetting("auto_hide", checked)
                    }
                }

                ToggleSetting {
                    id: tempToggle
                    width: parent.width
                    title: "Hiển thị nhiệt độ"
                    onToggled: function(checked) {
                        if (bridge) bridge.updateSetting("show_temperature", checked)
                    }
                }
            }
        }
    }
}
