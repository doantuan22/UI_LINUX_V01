pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#050B14"
    readonly property color bgDark: "#06111F"
    readonly property color overlayDim: Qt.rgba(0.0, 0.0, 0.0, 0.30)
    readonly property color glassPanel: Qt.rgba(0.05, 0.10, 0.17, 0.88)
    readonly property color glassPanelStrong: Qt.rgba(0.04, 0.08, 0.14, 0.92)
    readonly property color glassCard: Qt.rgba(1, 1, 1, 0.13)
    readonly property color glassCardHover: Qt.rgba(1, 1, 1, 0.18)
    readonly property color border: Qt.rgba(1, 1, 1, 0.30)
    readonly property color borderSoft: Qt.rgba(1, 1, 1, 0.20)
    readonly property color borderActive: Qt.rgba(0.20, 0.70, 1.0, 0.65)
    readonly property color textPrimary: "#F5F9FF"
    readonly property color textSecondary: "#B8C4D6"
    readonly property color textMuted: "#8D9AAF"

    readonly property color cpuAccent: "#35C7FF"
    readonly property color gpuAccent: "#35E27A"
    readonly property color ramAccent: "#A855F7"
    readonly property color diskAccent: "#FACC15"
    readonly property color tempAccent: "#FB7185"
    readonly property color fanAccent: "#22D3EE"

    readonly property color accentBlue: "#35C7FF"
    readonly property color accentGreen: "#35E27A"
    readonly property color accentPurple: "#A855F7"
    readonly property color accentYellow: "#FACC15"
    readonly property color accentRed: "#FB7185"
    readonly property color accentCyan: "#22D3EE"

    readonly property color danger: "#FF5C7A"
    readonly property color warning: "#FACC15"
    readonly property color success: "#35E27A"
}
