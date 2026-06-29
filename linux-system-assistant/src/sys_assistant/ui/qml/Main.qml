import QtQuick
import QtQuick.Controls

FloatingIcon {
    id: floatingIcon
    bridge: sysBridge
    dashboard: dashboard

    DesktopOverlay {
        id: dashboard
        bridge: sysBridge
        anchorPoint: Qt.point(floatingIcon.x, floatingIcon.y)
        onHiddenRequested: floatingIcon.visible = true

        Connections {
            target: floatingIcon
            function onXChanged() { dashboard.anchorPoint = Qt.point(floatingIcon.x, floatingIcon.y) }
            function onYChanged() { dashboard.anchorPoint = Qt.point(floatingIcon.x, floatingIcon.y) }
        }
    }
}
