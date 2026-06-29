pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#03101B"
    readonly property color bgDark: "#071625"
    readonly property color panelBg: Qt.rgba(0.02, 0.095, 0.15, 0.93)
    readonly property color panelBgStrong: Qt.rgba(0.018, 0.075, 0.13, 0.97)
    readonly property color panelBgSolid: "#081827"
    readonly property color cardBg: Qt.rgba(0.16, 0.27, 0.36, 0.46)
    readonly property color cardBgHover: Qt.rgba(0.20, 0.34, 0.45, 0.58)
    readonly property color cardBgSolid: "#122334"
    readonly property color overlayDim: Qt.rgba(0.0, 0.0, 0.0, 0.34)
    readonly property color glassPanel: panelBg
    readonly property color glassPanelStrong: panelBgStrong
    readonly property color glassCard: cardBg
    readonly property color glassCardHover: cardBgHover
    readonly property color border: Qt.rgba(0.56, 0.75, 0.88, 0.36)
    readonly property color borderSoft: Qt.rgba(0.58, 0.75, 0.86, 0.24)
    readonly property color borderActive: Qt.rgba(0.13, 0.95, 0.93, 0.72)
    readonly property color textPrimary: "#F5F9FF"
    readonly property color textSecondary: "#C6D2E2"
    readonly property color textMuted: "#98A6BA"

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
    readonly property color info: "#35C7FF"
    readonly property color disabled: "#8492A8"
    readonly property color protectedColor: "#FACC15"

    readonly property int animFast: 120
    readonly property int animNormal: 180
    readonly property int animSlow: 260
}
