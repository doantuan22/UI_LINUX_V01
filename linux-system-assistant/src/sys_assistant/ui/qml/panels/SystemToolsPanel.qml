import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root

    property var bridge
    property bool running: false
    property string currentView: "menu" // "menu", "check", "cleanup", "hardware"

    // System check state
    property var checkReport: null
    property bool checkDetailVisible: false

    // Cleanup state
    property var scanReport: null
    property var cleanupResult: null
    property var selectedCleanupIds: []

    // Hardware state
    property var hwReport: null

    clip: true

    function backToMenu() {
        currentView = "menu"
        running = false
        checkDetailVisible = false
    }

    function copyToClipboard(text) {
        clipHelper.text = text
        clipHelper.selectAll()
        clipHelper.copy()
    }

    function statusColor(status) {
        if (status === "error") return Theme.danger
        if (status === "warning") return Theme.warning
        if (status === "ok") return Theme.success
        return Theme.textMuted
    }

    function hardwareLabel(key) {
        var labels = {
            "cpu": "CPU",
            "gpu": "GPU",
            "ram": "RAM",
            "swap": "Swap",
            "disk": "Ổ đĩa",
            "network": "Mạng",
            "battery": "Pin"
        }
        return labels[key] || key
    }

    function hardwareValue(item) {
        if (!item) return "Không khả dụng"
        var text = item.ui_text || item.name || "Không khả dụng"
        var prefix = hardwareLabel(item.key) + ": "
        if (text.indexOf(prefix) === 0)
            return text.slice(prefix.length)
        return text
    }

    TextEdit {
        id: clipHelper
        visible: false
        width: 0; height: 0
    }

    Connections {
        target: bridge
        function onActionCompleted(action, result) {
            if (action === "system_check") {
                checkReport = result
                running = false
            } else if (action === "scan_cleanup") {
                scanReport = result
                selectedCleanupIds = []
                if (result && result.targets) {
                    for (var i = 0; i < result.targets.length; i++) {
                        if (result.targets[i].default_selected)
                            selectedCleanupIds.push(result.targets[i].id)
                    }
                }
                running = false
            } else if (action === "run_cleanup") {
                cleanupResult = result
                running = false
                runCleanupScan(false)
            } else if (action === "hardware_info") {
                hwReport = result
                running = false
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: Metrics.gapMedium

        // === MENU VIEW ===
        PanelHeader {
            visible: currentView === "menu"
            title: "Công cụ hệ thống"
            iconText: "🛠"
            iconColor: Theme.accentCyan
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            // --- MENU ---
            ScrollView {
                id: menuView
                anchors.fill: parent
                visible: currentView === "menu"
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
                        showIcon: false
                        accentColor: Theme.accentGreen
                        onClicked: {
                            currentView = "check"
                            if (!checkReport) runSystemCheck()
                        }
                    }

                    ToolActionRow {
                        width: parent.width
                        title: "Dọn dẹp hệ thống"
                        subtitle: "Quét và dọn cache an toàn"
                        showIcon: false
                        accentColor: Theme.accentYellow
                        onClicked: currentView = "cleanup"
                    }

                    ToolActionRow {
                        width: parent.width
                        title: "Thông tin phần cứng"
                        subtitle: "CPU, GPU, RAM, ổ đĩa, mạng, pin"
                        showIcon: false
                        accentColor: Theme.accentCyan
                        onClicked: {
                            currentView = "hardware"
                            loadHardwareInfo()
                        }
                    }
                }
            }

            // --- SYSTEM CHECK VIEW ---
            ColumnLayout {
                anchors.fill: parent
                visible: currentView === "check"
                spacing: Metrics.gapMedium

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.gapSmall
                    SystemActionButton {
                        label: "Quay lại"; iconGlyph: "‹"
                        Layout.preferredWidth: 69
                        onClicked: backToMenu()
                    }
                    GlowIcon { iconText: "✓"; iconSize: 14; color: Theme.accentGreen }
                    Text {
                        Layout.fillWidth: true
                        text: "Kiểm tra hệ thống"
                        color: Theme.textPrimary
                        font.pixelSize: Metrics.fontBody; font.bold: true
                        elide: Text.ElideRight
                    }
                }

                // Loading state
                Text {
                    visible: running
                    Layout.fillWidth: true
                    text: "Đang kiểm tra hệ thống..."
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                }

                // Results
                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !running && checkReport !== null
                    hoverEnabled: false
                    borderColor: {
                        if (!checkReport) return Theme.borderSoft
                        var s = checkReport.overall_status
                        return s === "error" ? Theme.danger : (s === "warning" ? Theme.warning : Theme.success)
                    }
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        // Overall badge
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            Rectangle {
                                width: 10; height: 10; radius: 5
                                color: {
                                    if (!checkReport) return Theme.textMuted
                                    var s = checkReport.overall_status
                                    return s === "error" ? Theme.danger : (s === "warning" ? Theme.warning : Theme.success)
                                }
                            }
                            Text {
                                text: (checkReport && checkReport.overall_label !== undefined) ? checkReport.overall_label : ""
                                color: Theme.textPrimary
                                font.pixelSize: Metrics.fontBody; font.bold: true
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                visible: checkReport !== null
                                text: checkReport ? new Date(checkReport.checked_at).toLocaleTimeString(Qt.locale(), "HH:mm:ss") : ""
                                color: Theme.textMuted
                                font.pixelSize: Metrics.fontCaption
                            }
                        }

                        // Summary or Detail
                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            Column {
                                width: parent.width
                                spacing: 4

                                // Summary rows
                                Repeater {
                                    model: checkReport ? checkReport.ui_summary : []
                                    delegate: RowLayout {
                                        width: parent.width
                                        spacing: 8
                                        Rectangle {
                                            width: 8; height: 8; radius: 4
                                            color: {
                                                var s = modelData.status
                                                return s === "error" ? Theme.danger : (s === "warning" ? Theme.warning : (s === "ok" ? Theme.success : Theme.textMuted))
                                            }
                                        }
                                        Text {
                                            text: modelData.label
                                            color: Theme.textPrimary
                                            font.pixelSize: Metrics.fontCaption
                                            Layout.preferredWidth: 70
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.status_label
                                            color: {
                                                var s = modelData.status
                                                return s === "error" ? Theme.danger : (s === "warning" ? Theme.warning : Theme.textSecondary)
                                            }
                                            font.pixelSize: Metrics.fontCaption
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    visible: !running && checkReport === null
                    Layout.fillWidth: true
                    text: "Chưa chạy kiểm tra"
                    color: Theme.textMuted
                    font.pixelSize: Metrics.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                }

                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.gapSmall
                    Item { Layout.fillWidth: true }
                    AppButton {
                        text: running ? "Đang chạy..." : (checkReport ? "Chạy lại" : "Chạy kiểm tra")
                        iconText: "▶"
                        variant: "primary"
                        buttonEnabled: !running
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: Metrics.buttonHeight
                        onClicked: if (!running) runSystemCheck()
                    }
                    AppButton {
                        visible: checkReport !== null && !running
                        text: "Chi tiết"
                        iconText: "⛶"
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: Metrics.buttonHeight
                        onClicked: checkDetailPopup.open()
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // --- CLEANUP VIEW ---
            ColumnLayout {
                anchors.fill: parent
                visible: currentView === "cleanup"
                spacing: Metrics.gapMedium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.gapSmall
                    SystemActionButton {
                        label: "Quay lại"; iconGlyph: "‹"
                        Layout.preferredWidth: 69
                        onClicked: backToMenu()
                    }
                    GlowIcon { iconText: "🧹"; iconSize: 14; color: Theme.accentYellow }
                    Text {
                        Layout.fillWidth: true
                        text: "Dọn dẹp hệ thống"
                        color: Theme.textPrimary
                        font.pixelSize: Metrics.fontBody; font.bold: true
                        elide: Text.ElideRight
                    }
                }

                // Loading
                Text {
                    visible: running
                    Layout.fillWidth: true
                    text: "Đang xử lý..."
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                }

                // Scan results
                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: !running && scanReport !== null
                    hoverEnabled: false
                    clip: true

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        // Total cleanable
                        Text {
                            Layout.fillWidth: true
                            text: scanReport ? "Tổng có thể dọn: " + scanReport.total_cleanable_label : ""
                            color: Theme.textPrimary
                            font.pixelSize: Metrics.fontBody; font.bold: true
                        }

                        ScrollView {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            clip: true
                            ScrollBar.vertical.policy: ScrollBar.AsNeeded
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                            Column {
                                id: cleanupRepeaterContainer
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    id: cleanupRepeater
                                    model: scanReport ? scanReport.targets : []
                                    delegate: RowLayout {
                                        width: parent.width
                                        spacing: 6
                                        property bool isChecked: modelData.default_selected

                                        Rectangle {
                                            width: 14; height: 14; radius: 3
                                            color: isChecked ? Theme.accentBlue : "transparent"
                                            border.width: 1
                                            border.color: isChecked ? Theme.accentBlue : Theme.borderSoft

                                            Text {
                                                anchors.centerIn: parent
                                                text: isChecked ? "✓" : ""
                                                color: "white"
                                                font.pixelSize: 12
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    isChecked = !isChecked
                                                    updateSelectedIds()
                                                }
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 1
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.title
                                                color: Theme.textPrimary
                                                font.pixelSize: Metrics.fontCaption
                                                elide: Text.ElideRight
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.size_label + (modelData.status === "warning" ? " - Cần xác nhận" : (modelData.status === "empty" ? " - Trống" : ""))
                                                color: modelData.status === "warning" ? Theme.warning : Theme.textMuted
                                                font.pixelSize: 10
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Cleanup result message
                        Text {
                            visible: cleanupResult !== null
                            Layout.fillWidth: true
                            text: cleanupResult ? "✓ " + cleanupResult.summary : ""
                            color: Theme.success
                            font.pixelSize: Metrics.fontCaption
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // Empty state
                Text {
                    visible: !running && scanReport === null && cleanupResult === null
                    Layout.fillWidth: true
                    text: "Chưa quét dữ liệu dọn dẹp."
                    color: Theme.textMuted
                    font.pixelSize: Metrics.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                }

                // Buttons
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    SystemActionButton {
                        label: scanReport ? "Quét lại" : "Quét"
                        iconGlyph: "🔍"
                        Layout.fillWidth: true
                        onClicked: if (!running) runCleanupScan()
                    }
                    SystemActionButton {
                        visible: scanReport !== null && !running
                        label: "Dọn mục đã chọn"
                        iconGlyph: "🧹"
                        Layout.fillWidth: true
                        onClicked: confirmCleanup()
                    }
                }
            }

            // --- HARDWARE VIEW ---
            ColumnLayout {
                anchors.fill: parent
                visible: currentView === "hardware"
                spacing: Metrics.gapMedium

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Metrics.gapSmall
                    SystemActionButton {
                        label: "Quay lại"; iconGlyph: "‹"
                        Layout.preferredWidth: 69
                        onClicked: backToMenu()
                    }
                    GlowIcon { iconText: "💻"; iconSize: 14; color: Theme.accentCyan }
                    Text {
                        Layout.fillWidth: true
                        text: "Thông tin phần cứng"
                        color: Theme.textPrimary
                        font.pixelSize: Metrics.fontBody; font.bold: true
                        elide: Text.ElideRight
                    }
                }

                // Loading
                Text {
                    visible: running && hwReport === null
                    Layout.fillWidth: true
                    text: "Đang lấy thông tin..."
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontCaption
                    horizontalAlignment: Text.AlignHCenter
                }

                // Hardware cards
                GlassCard {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: hwReport !== null
                    hoverEnabled: false
                    clip: true

                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 10
                        clip: true
                        ScrollBar.vertical.policy: ScrollBar.AsNeeded
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                        Column {
                            width: parent.width
                            spacing: 6

                            Repeater {
                                model: {
                                    if (!hwReport || !hwReport.hardware) return []
                                    var hw = hwReport.hardware
                                    var items = []
                                    var keys = ["cpu", "gpu", "ram", "swap", "disk", "network", "battery"]
                                    var colors = {"cpu": Theme.cpuAccent, "gpu": Theme.gpuAccent, "ram": Theme.ramAccent, "swap": Theme.accentPurple, "disk": Theme.diskAccent, "network": Theme.accentCyan, "battery": Theme.accentGreen}
                                    for (var i = 0; i < keys.length; i++) {
                                        var k = keys[i]
                                        if (hw[k]) {
                                            var item = hw[k]
                                            item.key = k
                                            item.color = colors[k]
                                            items.push(item)
                                        }
                                    }
                                    return items
                                }
                                delegate: InfoRow {
                                    width: parent.width
                                    label: root.hardwareLabel(modelData.key)
                                    value: root.hardwareValue(modelData)
                                    indicatorColor: modelData.color || root.statusColor(modelData.status)
                                }
                            }

                        }
                    }
                }
            }
        }
    }

    // Cleanup confirm dialog
    ConfirmDialog {
        id: cleanupConfirmDialog
        title: "Xác nhận dọn dẹp"
        property bool hasTrash: false

        message: hasTrash
            ? "Bạn có chắc muốn dọn các mục đã chọn?\n\n⚠ Thùng rác sẽ bị xóa vĩnh viễn!"
            : "Bạn có chắc muốn dọn các mục đã chọn?"
        confirmText: "Dọn dẹp"

        onConfirmed: executeCleanup()
    }

    // System Check Detail Popup
    Popup {
        id: checkDetailPopup
        modal: true
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: 480
        height: 400
        padding: 0
        background: Rectangle {
            color: Theme.panelBgSolid
            radius: Metrics.cardRadius
            border.width: 1
            border.color: Theme.borderSoft
        }

        contentItem: ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: Metrics.gapMedium

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Chi tiết kiểm tra hệ thống"
                    color: Theme.textPrimary
                    font.pixelSize: 13
                    font.bold: true
                }
                SystemActionButton {
                    label: "Đóng"
                    iconGlyph: "✕"
                    onClicked: checkDetailPopup.close()
                }
            }

            // Scrollable Content
            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                Column {
                    width: parent.width
                    spacing: 12

                    Repeater {
                        model: checkReport ? checkReport.sections : []
                        delegate: Column {
                            width: parent.width
                            spacing: 6

                            RowLayout {
                                width: parent.width
                                spacing: 8
                                Rectangle {
                                    width: 10; height: 10; radius: 5
                                    color: {
                                        var s = modelData.status
                                        return s === "error" ? Theme.danger : (s === "warning" ? Theme.warning : (s === "ok" ? Theme.success : Theme.textMuted))
                                    }
                                }
                                Text {
                                    text: modelData.title
                                    color: Theme.textPrimary
                                    font.pixelSize: Metrics.fontBody; font.bold: true
                                }
                                Item { Layout.fillWidth: true }
                            }

                            Text {
                                width: parent.width
                                text: modelData.summary || ""
                                color: Theme.textSecondary
                                font.pixelSize: Metrics.fontBody
                                wrapMode: Text.WordWrap
                                visible: (modelData.summary || "") !== ""
                            }

                            Text {
                                width: parent.width
                                text: modelData.suggestion || ""
                                color: Theme.warning
                                font.pixelSize: Metrics.fontBody
                                wrapMode: Text.WordWrap
                                visible: (modelData.suggestion || "") !== ""
                            }

                            RowLayout {
                                width: parent.width
                                spacing: 8
                                visible: root.canCopyCheckLog(modelData)

                                Text {
                                    Layout.fillWidth: true
                                    text: "Log lỗi có thể sao chép"
                                    color: Theme.warning
                                    font.pixelSize: Metrics.fontCaption
                                    elide: Text.ElideRight
                                }

                                SystemActionButton {
                                    label: "Sao chép lỗi"
                                    iconGlyph: "📋"
                                    Layout.preferredWidth: 94
                                    onClicked: root.copyCheckLog(modelData)
                                }
                            }

                            // Raw output box
                            Rectangle {
                                visible: (modelData.raw_output || "") !== ""
                                width: parent.width
                                height: rawTextPopup.implicitHeight + 16
                                color: Theme.cardBgSolid
                                radius: 6
                                border.width: 1
                                border.color: Qt.rgba(1, 1, 1, 0.10)

                                Text {
                                    id: rawTextPopup
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: modelData.raw_output || ""
                                    color: Theme.textMuted
                                    font.family: "monospace"
                                    font.pixelSize: 11
                                    wrapMode: Text.WrapAnywhere
                                }
                            }

                            Rectangle {
                                width: parent.width
                                height: 1
                                color: Theme.borderSoft
                                visible: index < checkReport.sections.length - 1
                            }
                        }
                    }
                }
            }
        }
    }

    // === JS functions ===
    function runSystemCheck() {
        if (!bridge || running) return
        running = true
        checkReport = null
        checkDetailVisible = false
        if (!bridge.requestSystemCheck()) {
            running = false
        }
    }

    function runCleanupScan(clearResult) {
        if (!bridge || running) return
        running = true
        scanReport = null
        if (clearResult !== false)
            cleanupResult = null
        if (!bridge.requestCleanupScan()) {
            running = false
        }
    }

    function updateSelectedIds() {
        if (!scanReport || !scanReport.targets) return
        var ids = []
        // Read checkbox states from repeater children
        var targets = scanReport.targets
        // Use a simple approach: iterate and check
        for (var i = 0; i < targets.length; i++) {
            // For simplicity, we track via the model's default_selected or user clicks
            // This is handled by the delegate isChecked property
        }
        // Since QML delegate properties are scoped, we re-collect from the repeater
        selectedCleanupIds = ids
    }

    function confirmCleanup() {
        if (!scanReport) return
        // Collect selected IDs by scanning repeater
        var ids = getSelectedIds()
        if (ids.length === 0) return

        selectedCleanupIds = ids
        cleanupConfirmDialog.hasTrash = ids.indexOf("trash") >= 0
        cleanupConfirmDialog.open()
    }

    function getSelectedIds() {
        var ids = []
        if (!scanReport || !scanReport.targets) return ids
        for (var i = 0; i < cleanupRepeater.count; i++) {
            var item = cleanupRepeater.itemAt(i)
            if (item && item.isChecked && i < scanReport.targets.length) {
                ids.push(scanReport.targets[i].id)
            }
        }
        return ids
    }

    function executeCleanup() {
        if (!bridge || running) return
        var ids = selectedCleanupIds
        if (ids.length === 0) return
        running = true
        var hasTrash = ids.indexOf("trash") >= 0
        if (!bridge.requestRunCleanup(ids, hasTrash))
            running = false
    }

    function loadHardwareInfo() {
        if (!bridge) return
        running = true
        if (!bridge.requestHardwareInfo()) {
            running = false
        }
    }

    function canCopyCheckLog(section) {
        if (!section)
            return false
        if (section.id !== "log")
            return false
        if (!(section.raw_output || ""))
            return false
        return section.status === "warning" || section.status === "error"
    }

    function copyCheckLog(section) {
        if (!canCopyCheckLog(section))
            return
        var lines = [
            "=== Log lỗi kiểm tra hệ thống ===",
            "Trạng thái: " + (section.status || ""),
            "Tóm tắt: " + (section.summary || ""),
            "Thời gian: " + (checkReport ? (checkReport.checked_at || "") : ""),
            "",
            section.raw_output || ""
        ]
        copyToClipboard(lines.join("\n"))
    }

}
