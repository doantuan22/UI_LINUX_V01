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

    property bool dragging: false
    property point dragStart: Qt.point(0, 0)
    property point windowStart: Qt.point(0, 0)

    GlassPanel {
        anchors.fill: parent
        radiusSize: Metrics.iconSize / 2
        opacity: dragging ? 0.8 : 1.0

        Rectangle {
            anchors.centerIn: parent
            width: 28
            height: 28
            radius: 14
            gradient: Gradient {
                GradientStop { position: 0; color: Theme.cpuAccent }
                GradientStop { position: 1; color: Theme.gpuAccent }
            }
        }

        Text {
            anchors.centerIn: parent
            text: "⚡"
            font.pixelSize: 22
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
                dashboard.togglePanel()
        }
    }

    Menu {
        id: contextMenu
        MenuItem {
            text: "Open Dashboard"
            onTriggered: { if (dashboard) dashboard.openPanel() }
        }
        MenuItem {
            text: "Settings"
            onTriggered: {
                if (dashboard) {
                    dashboard.openPanel()
                    dashboard.settingsVisible = true
                    dashboard.processesVisible = false
                }
            }
        }
        MenuSeparator {}
        MenuItem {
            text: "Quit"
            onTriggered: Qt.quit()
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
