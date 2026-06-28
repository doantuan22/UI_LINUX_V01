pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#050B14"
    readonly property color glassPanel: Qt.rgba(0.07, 0.11, 0.18, 0.88)
    readonly property color glassCard: Qt.rgba(1, 1, 1, 0.12)
    readonly property color glassCardHover: Qt.rgba(1, 1, 1, 0.20)
    readonly property color border: Qt.rgba(1, 1, 1, 0.25)
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#AEB9C8"
    readonly property color textMuted: "#718096"

    readonly property color cpuAccent: "#35C7FF"
    readonly property color gpuAccent: "#35E27A"
    readonly property color ramAccent: "#A855F7"
    readonly property color diskAccent: "#FACC15"
    readonly property color tempAccent: "#FB7185"
    readonly property color fanAccent: "#22D3EE"
    readonly property color danger: "#FF5C7A"
    readonly property color warning: "#FACC15"
    readonly property color success: "#35E27A"
}
