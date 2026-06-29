import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root

    property var bridge
    property bool running: false
    property bool detailVisible: false
    property bool resultOk: true
    property string detailTitle: ""
    property string detailSubtitle: ""
    property string detailIcon: "✓"
    property color detailColor: Theme.accentGreen
    property string detailMessage: ""

    clip: true

    function openDetail(title, subtitle, icon, color) {
        root.detailTitle = title
        root.detailSubtitle = subtitle
        root.detailIcon = icon
        root.detailColor = color
        root.resultOk = true
        root.detailMessage = "Đang xử lý..."
        root.detailVisible = true
        root.running = true
    }

    function finishDetail(ok, message) {
        root.resultOk = ok
        root.detailMessage = message
        root.running = false
    }

    function backToMenu() {
        root.detailVisible = false
        root.running = false
    }

    function runSystemCheckAction() {
        if (!bridge || running)
            return
        openDetail("Kiểm tra hệ thống", "Kiểm tra lỗi, driver, dịch vụ và hiệu suất", "✓", Theme.accentGreen)
        Qt.callLater(function() {
            var result = bridge.runSystemCheck()
            var lines = []
            if (result && result.items) {
                for (var i = 0; i < result.items.length; ++i) {
                    var item = result.items[i]
                    lines.push("• " + item.name + ": " + item.status + " - " + item.detail)
                }
            }
            finishDetail(result && result.status !== "error",
                         lines.length ? lines.join("\n") : "Không có dữ liệu kiểm tra.")
        })
    }

    function runCleanupAction() {
        if (!bridge || running)
            return
        openDetail("Dọn dẹp hệ thống", "Dọn cache thumbnail an toàn", "🧹", Theme.accentYellow)
        Qt.callLater(function() {
            var result = bridge.cleanThumbnailCache()
            finishDetail(result && result.ok, result && result.message ? result.message : "Đã hoàn tất.")
        })
    }

    function showHardwareInfo() {
        if (!bridge || running)
            return
        openDetail("Thông tin phần cứng", "Tóm tắt CPU, GPU, RAM và ổ đĩa", "💻", Theme.accentCyan)
        Qt.callLater(function() {
            var s = bridge.getStats()
            var cpu = s.cpu || {}
            var gpu = s.gpu || {}
            var ram = s.ram || {}
            var disk = s.disk || {}
            finishDetail(true,
                         "CPU: " + Math.round(cpu.usage || 0) + "%, " + (cpu.freq_ghz || "--") + " GHz\n" +
                         "GPU: " + (gpu.name || "unavailable") + "\n" +
                         "RAM: " + (ram.used_gb || 0) + " / " + (ram.total_gb || 0) + " GB\n" +
                         "Disk: " + (disk.used_gb || 0) + " / " + (disk.total_gb || 0) + " GB")
        })
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: Metrics.gapMedium

        PanelHeader {
            visible: !root.detailVisible
            title: "Công cụ hệ thống"
            iconText: "🔧"
            iconColor: Theme.accentPurple
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ScrollView {
                id: menuView
                anchors.fill: parent
                visible: !root.detailVisible
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: menuView.availableWidth
                    spacing: Metrics.gapMedium

                    ToolActionRow {
                        width: parent.width
                        title: "Kiểm tra hệ thống"
                        subtitle: "Kiểm tra lỗi, driver, dịch vụ và hiệu suất"
                        iconText: "✓"
                        accentColor: Theme.accentGreen
                        onClicked: root.runSystemCheckAction()
                    }

                    ToolActionRow {
                        width: parent.width
                        title: "Dọn dẹp hệ thống"
                        subtitle: "Dọn cache thumbnail an toàn"
                        iconText: "🧹"
                        accentColor: Theme.accentYellow
                        onClicked: root.runCleanupAction()
                    }

                    ToolActionRow {
                        width: parent.width
                        title: "Thông tin phần cứng"
                        subtitle: "Tóm tắt CPU, GPU, RAM và ổ đĩa"
                        iconText: "💻"
                        accentColor: Theme.accentCyan
                        onClicked: root.showHardwareInfo()
                    }
                }
            }

            ColumnLayout {
                id: detailView
                anchors.fill: parent
                spacing: Metrics.gapMedium
                visible: root.detailVisible

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.gapSmall

                    SystemActionButton {
                        label: "Quay lại"
                        iconGlyph: "‹"
                        Layout.preferredWidth: 86
                        onClicked: root.backToMenu()
                    }

                    GlowIcon {
                        iconText: root.detailIcon
                        iconSize: 18
                        color: root.detailColor
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: root.detailTitle
                            color: Theme.textPrimary
                            font.pixelSize: Metrics.fontBody
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.detailSubtitle
                            color: Theme.textSecondary
                            font.pixelSize: Metrics.fontCaption
                            elide: Text.ElideRight
                        }
                    }
                }

                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    hoverEnabled: false
                    borderColor: root.resultOk ? Theme.borderSoft : Theme.warning
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        Text {
                            Layout.fillWidth: true
                            text: root.running ? "Đang xử lý..." : (root.resultOk ? "Hoàn tất" : "Có cảnh báo")
                            color: root.resultOk ? Theme.textPrimary : Theme.warning
                            font.pixelSize: Metrics.fontBody
                            font.bold: true
                            elide: Text.ElideRight
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            Text {
                                width: parent.width
                                text: root.detailMessage
                                color: Theme.textSecondary
                                font.pixelSize: Metrics.fontCaption
                                wrapMode: Text.WordWrap
                            }
                        }
                    }
                }
            }
        }
    }
}
