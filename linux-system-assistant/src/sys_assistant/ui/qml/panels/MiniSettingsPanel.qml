import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root
    
    property var bridge
    clip: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 10
        
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

                Repeater {
                    model: [
                        { title: "Khởi động cùng hệ thống", desc: "Tự động mở ứng dụng khi đăng nhập" },
                        { title: "Tự động thu gọn", desc: "Thu gọn vào khay hệ thống khi đóng" }
                    ]
                    delegate: GlassCard {
                        width: parent.width
                        height: 60
                        hoverEnabled: false

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    color: Theme.textPrimary
                                    font.pixelSize: 13
                                    font.bold: true
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.desc
                                    color: Theme.textSecondary
                                    font.pixelSize: Metrics.fontCaption
                                }
                            }

                            AppBadge {
                                text: "Đang phát triển"
                                tone: "disabled"
                            }
                        }
                    }
                }
            }
        }
    }
}

