pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components"
import "../styles"

GlassPanel {
    id: root
    
    property var bridge
    property var processModel: []
    property var killDialog
    property bool autoRefreshEnabled: true
    clip: true

    ListModel {
        id: stableProcessModel
        dynamicRoles: true
    }

    function refreshProcesses(immediate) {
        if (!bridge)
            return

        bridge.requestTopProcesses()
    }

    function findProcessIndex(pid) {
        for (var i = 0; i < stableProcessModel.count; i++) {
            if (stableProcessModel.get(i).pid === pid)
                return i
        }
        return -1
    }

    function normalizedProcess(item) {
        var display = item.displayName || item.name || "Unknown"
        return {
            pid: item.pid || 0,
            processName: item.name || display,
            displayName: display,
            iconPath: item.iconPath || "",
            iconName: item.iconName || "",
            fallbackChar: item.fallbackLetter || (display.length > 0 ? display.charAt(0).toUpperCase() : "?"),
            cpuText: item.cpu !== undefined && item.cpu !== null ? Number(item.cpu).toFixed(1) : "0.0",
            ramText: item.memory_mb !== undefined && item.memory_mb !== null ? Number(item.memory_mb).toFixed(0) + " MB" : "0 MB",
            ramPercentText: item.memory_percent !== undefined && item.memory_percent !== null ? Number(item.memory_percent).toFixed(1) + "%" : "0.0%",
            protectedProcess: item.protected || false,
            killable: item.killable === true
        }
    }

    function fallbackFromText(value) {
        var text = String(value || "").trim()
        for (var i = 0; i < text.length; i++) {
            var ch = text.charAt(i)
            if (/[A-Za-z0-9]/.test(ch))
                return ch.toUpperCase()
        }
        return "?"
    }

    function setIfChanged(index, role, value) {
        if (stableProcessModel.get(index)[role] !== value)
            stableProcessModel.setProperty(index, role, value)
    }

    function applyProcessSnapshot(list) {
        if (!list)
            list = []
        var seen = {}
        for (var i = 0; i < list.length; i++) {
            var row = normalizedProcess(list[i])
            seen[row.pid] = true
            var idx = findProcessIndex(row.pid)
            if (idx < 0) {
                stableProcessModel.append(row)
                continue
            }
            setIfChanged(idx, "processName", row.processName)
            setIfChanged(idx, "displayName", row.displayName)
            setIfChanged(idx, "iconPath", row.iconPath)
            setIfChanged(idx, "iconName", row.iconName)
            setIfChanged(idx, "fallbackChar", row.fallbackChar)
            setIfChanged(idx, "cpuText", row.cpuText)
            setIfChanged(idx, "ramText", row.ramText)
            setIfChanged(idx, "ramPercentText", row.ramPercentText)
            setIfChanged(idx, "protectedProcess", row.protectedProcess)
            setIfChanged(idx, "killable", row.killable)
        }
        for (var j = stableProcessModel.count - 1; j >= 0; j--) {
            if (!seen[stableProcessModel.get(j).pid])
                stableProcessModel.remove(j)
        }
    }

    onProcessModelChanged: applyProcessSnapshot(processModel)

    Timer {
        id: processRefreshTimer
        interval: 3000
        repeat: true
        running: root.autoRefreshEnabled && root.visible && root.bridge !== null && root.bridge !== undefined
        triggeredOnStart: false
        onTriggered: root.refreshProcesses(false)
    }

    Connections {
        target: root.bridge
        function onProcessesUpdated(list) {
            root.processModel = list
        }
    }

    Component.onCompleted: {
        if (bridge) root.refreshProcesses()
        else {
            // Fallback demo data
            root.processModel = [
                { name: "Google Chrome", cpu: 12.5, memory_mb: 850, pid: 1001, protected: false },
                { name: "Visual Studio Code", cpu: 8.2, memory_mb: 620, pid: 1002, protected: false },
                { name: "Discord", cpu: 2.1, memory_mb: 240, pid: 1003, protected: false },
                { name: "systemd", cpu: 0.1, memory_mb: 15, pid: 1, protected: true },
                { name: "Spotify", cpu: 1.5, memory_mb: 180, pid: 1005, protected: false }
            ]
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Metrics.padding
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: Metrics.gapSmall

            PanelHeader {
                Layout.fillWidth: true
                title: "Quản lý tiến trình"
                iconText: "☰"
                iconColor: Theme.accentBlue
            }

            SystemActionButton {
                label: "Làm mới"
                iconGlyph: "↻"
                Layout.preferredWidth: 86
                onClicked: root.refreshProcesses()
            }
        }

        // Table Header
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 22
            clip: true

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                Item { Layout.preferredWidth: Metrics.processIconSize }

                Text {
                    Layout.fillWidth: true
                    text: "Tiến trình"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontBody
                    elide: Text.ElideRight
                }
                Text {
                    Layout.preferredWidth: Metrics.processCpuWidth
                    text: "CPU"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontBody
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    Layout.preferredWidth: Metrics.processRamWidth
                    text: "RAM"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontBody
                    horizontalAlignment: Text.AlignHCenter
                }
                Text {
                    Layout.preferredWidth: Metrics.processStatusWidth
                    text: "Trạng thái"
                    color: Theme.textSecondary
                    font.pixelSize: Metrics.fontBody
                    horizontalAlignment: Text.AlignHCenter
                }
                Item { Layout.preferredWidth: Metrics.killButtonWidth }
            }
        }

        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 6
            model: stableProcessModel
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            cacheBuffer: Metrics.processRowHeight * 4
            reuseItems: true
            add: null
            remove: null
            displaced: null
            populate: null
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Item {
                required property var model

                width: ListView.view ? ListView.view.width : 0
                height: Metrics.processRowHeight
                property string rowDisplayName: model.displayName || ""
                property string rowProcessName: model.processName || ""
                property string rowIconPath: model.iconPath || ""
                property string rowIconName: model.iconName || ""
                property string rowFallbackChar: model.fallbackChar || ""
                property string rowCpuText: model.cpuText || "0.0"
                property string rowRamText: model.ramText || "0 MB"
                property string rowRamPercentText: model.ramPercentText || "0.0%"
                property bool rowProtectedProcess: model.protectedProcess || false
                property bool rowKillable: model.killable === true
                property int rowPid: model.pid || 0

                ProcessRow {
                    anchors.fill: parent
                    name: parent.rowDisplayName || parent.rowProcessName || "Unknown"
                    iconPath: parent.rowIconPath
                    iconName: parent.rowIconName
                    fallbackGlyph: parent.rowFallbackChar || root.fallbackFromText(parent.rowDisplayName || parent.rowProcessName)
                    cpuText: parent.rowCpuText
                    ramText: parent.rowRamText
                    ramPercentText: parent.rowRamPercentText
                    protectedProcess: parent.rowProtectedProcess
                    killable: parent.rowKillable
                    pid: parent.rowPid

                    onKillRequested: function(reqPid) {
                        if (root.killDialog) {
                            root.killDialog.pidToKill = reqPid
                            root.killDialog.forceKill = false
                            root.killDialog.open()
                        }
                    }
                }
            }
        }
    }
}
