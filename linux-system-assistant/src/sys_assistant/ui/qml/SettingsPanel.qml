import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components
import styles

GlassPanel {
    id: root

    radiusSize: Metrics.cardRadius
    clip: true

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

                Repeater {
                    model: [
                        { title: "Khởi động cùng hệ thống", desc: "Tự động mở ứng dụng khi đăng nhập" },
                        { title: "Hiển thị nhiệt độ", desc: "Tùy biến dữ liệu nhiệt độ trên dashboard" },
                        { title: "Hiển thị tốc độ mạng", desc: "Tùy biến card network trên dashboard" },
                        { title: "Chế độ an toàn khi kết thúc tiến trình", desc: "Quy tắc UI/confirm nâng cao cho kill process" }
                    ]
                    delegate: GlassCard {
                        width: parent.width
                        height: 53
                        hoverEnabled: false

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: Metrics.gapSmall

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    color: Theme.textPrimary
                                    font.pixelSize: Metrics.fontBody
                                    font.bold: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.desc
                                    color: Theme.textSecondary
                                    font.pixelSize: Metrics.fontCaption
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
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
