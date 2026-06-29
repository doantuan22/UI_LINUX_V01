import QtQuick
import QtQuick.Controls
import QtQuick.Window
import components
import styles

Window {
    id: iconWindow

    property var bridge: sysBridge
    property var dashboard: null

    width: Metrics.iconSize
    height: Metrics.iconSize
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"
    visible: true

    property bool _ready: false

    Component.onCompleted: {
        var pos = bridge.getIconPosition()
        x = pos.x || 100
        y = pos.y || 100
        clampToScreen()
        _ready = true
    }

    // Removed continuous save on X/Y changed for performance

    function clampToScreen() {
        var margin = Math.max(8, Metrics.gapSmall)
        var minX = Screen.virtualX + margin
        var minY = Screen.virtualY + margin
        var maxX = Screen.virtualX + Screen.width - width - margin
        var maxY = Screen.virtualY + Screen.height - height - margin
        if (maxX < minX)
            maxX = minX
        if (maxY < minY)
            maxY = minY
        x = Math.max(minX, Math.min(x, maxX))
        y = Math.max(minY, Math.min(y, maxY))
    }

    function savePosition() {
        if (_ready) {
            clampToScreen()
            bridge.saveIconPosition(Math.round(x), Math.round(y))
        }
    }

    function showDashboard(saveBeforeOpen, hideIconAfterOpen) {
        if (!dashboard)
            return
        if (saveBeforeOpen !== false)
            savePosition()
        dashboard.anchorPoint = Qt.point(iconWindow.x, iconWindow.y)
        dashboard.openPanel()
        if (hideIconAfterOpen !== false)
            iconWindow.visible = false
    }

    property bool dragging: false
    property point dragStart: Qt.point(0, 0)
    property point windowStart: Qt.point(0, 0)

    Item {
        id: iconContent
        anchors.fill: parent

        transform: Scale {
            origin.x: iconContent.width / 2
            origin.y: iconContent.height / 2
            xScale: mainMouseArea.containsMouse && !dragging ? 1.05 : (dragging ? 0.95 : 1.0)
            yScale: mainMouseArea.containsMouse && !dragging ? 1.05 : (dragging ? 0.95 : 1.0)
        }

        Behavior on transform {
            ScaleAnimator { duration: 150; easing.type: Easing.OutQuad }
        }

        GlassPanel {
            anchors.fill: parent
            radiusSize: Metrics.iconSize / 2
            opacity: dragging ? 0.8 : 1.0

            // Add a stronger border for the floating icon
            border.color: Theme.borderActive
            border.width: 1

            // Pulse effect
            Rectangle {
                anchors.centerIn: parent
                width: parent.width - 2
                height: parent.height - 2
                radius: width / 2
                color: "transparent"
                border.color: Theme.accentPurple
                border.width: 2
                opacity: 0.3

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    NumberAnimation { from: 0.8; to: 1.1; duration: 1500; easing.type: Easing.InOutQuad }
                    NumberAnimation { from: 1.1; to: 0.8; duration: 1500; easing.type: Easing.InOutQuad }
                }
            }

            GlowIcon {
                anchors.centerIn: parent
                iconText: "⚡"
                iconSize: 26
                color: Theme.accentBlue
            }
        }
    }

    MouseArea {
        id: mainMouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true

        onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                contextMenu.popup()
                return
            }
            dragging = false
            dragStart = Qt.point(mouse.x, mouse.y)
            windowStart = Qt.point(iconWindow.x, iconWindow.y)
        }

        onPositionChanged: function(mouse) {
            if (!(mouse.buttons & Qt.LeftButton))
                return
            var dx = mouse.x - dragStart.x
            var dy = mouse.y - dragStart.y
            if (!dragging && (Math.abs(dx) > 4 || Math.abs(dy) > 4))
                dragging = true
            if (dragging) {
                iconWindow.x = windowStart.x + dx
                iconWindow.y = windowStart.y + dy
                iconWindow.clampToScreen()
                if (dashboard)
                    dashboard.anchorPoint = Qt.point(iconWindow.x, iconWindow.y)
            }
        }

        onReleased: function(mouse) {
            savePosition()
            if (mouse.button === Qt.LeftButton && !dragging && dashboard)
                iconWindow.showDashboard()
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: "Mở dashboard"
            onTriggered: iconWindow.showDashboard()
        }
        MenuItem {
            text: "Cài đặt"
            onTriggered: {
                if (dashboard) {
                    iconWindow.showDashboard()
                    if (dashboard.triggerFocus) dashboard.triggerFocus("miniSettings")
                }
            }
        }
        MenuSeparator {}
        MenuItem {
            text: "Thoát"
            onTriggered: {
                iconWindow.bridge.quitApp()
            }
        }
    }

    ToolTip {
        parent: iconWindow.contentItem
        visible: mainMouseArea.containsMouse && !dragging
        text: "Linux System Assistant"
        delay: 500
    }
}
