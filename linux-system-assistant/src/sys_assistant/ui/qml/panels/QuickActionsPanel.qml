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
        spacing: 10
        
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
                columnSpacing: Metrics.gapMedium

                QuickActionButton {
                    Layout.fillWidth: true
                    title: "Khởi động lại"
                    subtitle: "Cần confirm và whitelist\nan toàn trước khi bật"
                    iconText: "↻"
                    accentColor: Theme.textSecondary
                    buttonEnabled: false
                }

                QuickActionButton {
                    Layout.fillWidth: true
                    title: "Tắt máy"
                    subtitle: "Chưa bật backend\nshutdown an toàn"
                    iconText: "⏻"
                    accentColor: Theme.textSecondary
                    buttonEnabled: false
                }
            }
        }
    }
}

