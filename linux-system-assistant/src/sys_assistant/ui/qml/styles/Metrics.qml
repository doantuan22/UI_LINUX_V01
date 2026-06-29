pragma Singleton
import QtQuick

QtObject {
    readonly property int iconSize: 58
    readonly property int dashboardWidth: 960
    readonly property int dashboardHeight: 816
    readonly property int cardRadius: 20
    readonly property int panelRadius: 22
    readonly property int radiusPanel: 22
    readonly property int radiusCard: 14
    readonly property int radiusButton: 12
    readonly property int statCardSize: 120
    readonly property int padding: 16
    readonly property int paddingPanel: 16
    readonly property int paddingCard: 12
    readonly property int gap: 11
    readonly property int gapSmall: 6
    readonly property int gapMedium: 10
    readonly property int gapLarge: 14

    readonly property int fontAppTitle: 15
    readonly property int fontPanelTitle: 15
    readonly property int fontSectionTitle: 13
    readonly property int fontCardValue: 18
    readonly property int fontCardLabel: 13
    readonly property int fontCardSub: 11
    readonly property int fontBody: 12
    readonly property int fontCaption: 11

    readonly property int processRowHeight: 46
    readonly property int processIconSize: 30
    readonly property int processCpuWidth: 54
    readonly property int processRamWidth: 64
    readonly property int killButtonWidth: 90
    readonly property int quickActionMinHeight: 56
}
