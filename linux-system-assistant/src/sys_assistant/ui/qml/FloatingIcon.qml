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
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
    color: "transparent"
    visible: true

    property bool _ready: false

    Component.onCompleted: {
        var pos = bridge.getIconPosition()
        x = pos.x || 100
        y = pos.y || 100
        _ready = true
    }

    // Removed continuous save on X/Y changed for performance

    function savePosition() {
        if (_ready)
            bridge.saveIconPosition(Math.round(x), Math.round(y))
    }

    function showDashboard() {
        if (!dashboard)
            return
        savePosition()
        dashboard.anchorPoint = Qt.point(iconWindow.x, iconWindow.y)
        dashboard.openPanel()
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
            xScale: iconArea.containsMouse && !dragging ? 1.05 : (dragging ? 0.95 : 1.0)
            yScale: iconArea.containsMouse && !dragging ? 1.05 : (dragging ? 0.95 : 1.0)
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
        visible: iconArea.containsMouse && !dragging
        text: "Linux System Assistant"
        delay: 500
    }

    MouseArea {
        id: iconArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: false
    }
}
