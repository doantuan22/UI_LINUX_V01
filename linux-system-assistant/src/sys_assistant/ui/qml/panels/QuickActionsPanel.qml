import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root
    clip: true
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 12
        
        PanelHeader {
            title: "Thao tác nhanh"
            iconText: "⚡"
            iconColor: Theme.accentBlue
        }
        
        ScrollView {
            id: quickScroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            GridLayout {
                width: quickScroll.availableWidth
                columns: 2
                rowSpacing: Metrics.gapSmall
                columnSpacing: Metrics.gapMedium

                QuickActionButton {
                    Layout.fillWidth: true
                    title: "Khởi động lại"
                    iconText: "↻"
                    accentColor: Theme.accentYellow
                    buttonEnabled: false // Safety disabled for now
                }

                QuickActionButton {
                    Layout.fillWidth: true
                    title: "Tắt máy"
                    iconText: "⏻"
                    accentColor: Theme.accentRed
                    buttonEnabled: false // Safety disabled for now
                }

                QuickActionButton {
                    Layout.fillWidth: true
                    title: "Đăng xuất"
                    iconText: "🚪"
                    accentColor: Theme.accentPurple
                    buttonEnabled: false // Safety disabled for now
                }

                QuickActionButton {
                    Layout.fillWidth: true
                    title: "Khóa màn hình"
                    iconText: "🔒"
                    accentColor: Theme.accentCyan
                    buttonEnabled: false // Safety disabled for now
                }
            }
        }
    }
}
