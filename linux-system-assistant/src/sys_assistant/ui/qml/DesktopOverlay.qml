import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import components
import "panels"
import styles

Window {
    id: overlay

    property var bridge: sysBridge
    property point anchorPoint: Qt.point(100, 100)
    signal hiddenRequested()

    property real availableWidth: Screen.desktopAvailableWidth > 0 ? Screen.desktopAvailableWidth : Screen.width
    property real availableHeight: Screen.desktopAvailableHeight > 0 ? Screen.desktopAvailableHeight : Screen.height
    property real responsiveScale: Math.min(
        1.0,
        Math.max(0.72, Math.min((availableWidth - 24) / Metrics.dashboardWidth,
                                (availableHeight - 24) / Metrics.dashboardHeight))
    )

    width: Math.round(Metrics.dashboardWidth * responsiveScale)
    height: Math.round(Metrics.dashboardHeight * responsiveScale)
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: false

    x: Math.max(0, Math.min(anchorPoint.x + Metrics.iconSize + 12, availableWidth - width - 8))
    y: Math.max(0, Math.min(anchorPoint.y - 40, availableHeight - height - 8))

    property real panelOpacity: 0
    property real panelScale: 0.96

    function openPanel() {
        visible = true
        show()
        raise()
        requestActivate()
        panelOpacity = 1
        panelScale = 1
        if (bridge) bridge.requestTopProcesses()
    }

    function closePanel() {
        panelOpacity = 0
        panelScale = 0.96
        visible = false
    }

    function hideApp() {
        closePanel()
        hiddenRequested()
    }

    function togglePanel() {
        if (visible) closePanel()
        else openPanel()
    }

    function triggerFocus(target) {
        var panel = null
        if (target === "sysTools") panel = sysTools
        else if (target === "processPanel") panel = processPanel
        else if (target === "miniSettings") panel = miniSettingsPanel
        
        if (panel) {
            var anim = Qt.createQmlObject('import QtQuick; SequentialAnimation { NumberAnimation { target: panel; property: "scale"; from: 1.0; to: 1.02; duration: 120 } NumberAnimation { target: panel; property: "scale"; from: 1.02; to: 1.0; duration: 120 } }', panel);
            anim.start();
            panel.active = true;
            Qt.createQmlObject('import QtQuick; Timer { interval: 1000; running: true; onTriggered: panel.active = false }', panel);
        }
    }

    Item {
        id: overlayContent
        width: Metrics.dashboardWidth
        height: Metrics.dashboardHeight
        opacity: overlay.panelOpacity
        clip: true
        transform: Scale {
            origin.x: 0
            origin.y: 0
            xScale: overlay.panelScale * overlay.responsiveScale
            yScale: overlay.panelScale * overlay.responsiveScale
        }
        
        Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutQuad } }

        Rectangle {
            anchors.fill: parent
            radius: Metrics.panelRadius
            color: Theme.overlayDim
        }

        Item {
            anchors.fill: parent
            anchors.margins: Metrics.padding
            
            // Top Row
            Item {
                id: topRow
                width: parent.width
                height: 597
                anchors.top: parent.top
                
                MainMonitorPanel {
                    id: mainMonitor
                    width: 538
                    height: 597
                    anchors.top: parent.top
                    anchors.left: parent.left
                    bridge: overlay.bridge
                    onHideRequested: overlay.hideApp()
                    onFocusRequested: overlay.triggerFocus(targetPanel)
                }

                SystemToolsPanel {
                    id: sysTools
                    width: 467
                    height: 259
                    anchors.top: parent.top
                    anchors.right: parent.right
                    bridge: overlay.bridge
                }

                ProcessPanel {
                    id: processPanel
                    width: 467
                    height: 317
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    bridge: overlay.bridge
                    killDialog: killConfirm
                    autoRefreshEnabled: overlay.visible
                }
            }
            
            // Bottom Row
            Item {
                id: bottomRow
                width: parent.width
                height: 190
                anchors.bottom: parent.bottom
                
                NotificationPanel {
                    id: notificationPanel
                    width: 339
                    height: parent.height
                    anchors.left: parent.left
                    bridge: overlay.bridge
                }
                
                QuickActionsPanel {
                    id: quickActionsPanel
                    width: 336
                    height: parent.height
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                MiniSettingsPanel {
                    id: miniSettingsPanel
                    width: 317
                    height: parent.height
                    anchors.right: parent.right
                    bridge: overlay.bridge
                }
            }
        }
    }
    
    ConfirmDialog {
        id: killConfirm
        property int pidToKill: 0
        property bool forceKill: false
        title: forceKill ? "Buộc kết thúc tiến trình?" : "Kết thúc tiến trình?"
        message: forceKill
            ? "Process vẫn còn chạy. Gửi SIGKILL cho PID " + pidToKill + "?"
            : "Gửi SIGTERM tới PID " + pidToKill + "?"
        confirmText: forceKill ? "Buộc kết thúc" : "Kết thúc"
        onConfirmed: {
            if (overlay.bridge) {
                var result = overlay.bridge.killProcess(pidToKill, forceKill)
                if (!forceKill) {
                    Qt.createQmlObject('import QtQuick; Timer { interval: 500; running: true; onTriggered: { if (overlay.bridge.isProcessAlive(killConfirm.pidToKill)) { killConfirm.forceKill = true; killConfirm.open(); } else { overlay.bridge.requestTopProcesses(); } this.destroy(); } }', overlay);
                } else {
                    overlay.bridge.requestTopProcesses()
                }
            }
        }
    }
}
