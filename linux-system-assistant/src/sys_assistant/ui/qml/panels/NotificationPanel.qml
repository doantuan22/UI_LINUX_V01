import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root

    property var bridge
    property var logModel: []

    clip: true

    function loadLogs() {
        if (bridge)
            logModel = bridge.getErrorLogs()
    }

    Component.onCompleted: loadLogs()

    Connections {
        target: bridge
        function onErrorLogsUpdated(logs) {
            root.logModel = logs
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapSmall

            PanelHeader {
                Layout.fillWidth: true
                title: "Log lỗi"
                iconText: "⚠"
                iconColor: Theme.warning
            }

            SystemActionButton {
                label: "Xóa"
                iconGlyph: "✕"
                Layout.preferredWidth: 54
                visible: root.logModel.length > 0
                onClicked: {
                    if (root.bridge)
                        root.bridge.clearErrorLogs()
                }
            }
        }

        GlassCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.logModel.length === 0
            hoverEnabled: false

            EmptyState {
                anchors.fill: parent
                anchors.margins: 10
                title: "Không có lỗi"
                message: "Đây là log runtime của ứng dụng.\nPhiên chạy hiện tại chưa ghi nhận lỗi\nnghiêm trọng."
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.logModel.length > 0
            clip: true
            spacing: 8
            model: root.logModel
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: NotificationCard {
                width: ListView.view.width
                level: modelData.level === "error" ? "danger" : "warning"
                title: modelData.title || "Runtime"
                message: modelData.message || ""
                timeText: modelData.time || ""
            }
        }
    }
}

