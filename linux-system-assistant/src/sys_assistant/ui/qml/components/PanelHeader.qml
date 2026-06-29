import QtQuick
import QtQuick.Layouts
import "../styles"

Item {
    id: root
    
    property string title: ""
    property string subtitle: ""
    property string iconText: ""
    property color iconColor: Theme.accentBlue
    
    Layout.fillWidth: true
    height: 29

    RowLayout {
        anchors.fill: parent
        spacing: Metrics.gapSmall
        
        GlowIcon {
            visible: root.iconText !== ""
            iconText: root.iconText
            iconSize: 16
            color: root.iconColor
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            
            Text {
                text: root.title
                color: Theme.textPrimary
                font.pixelSize: Metrics.fontPanelTitle
                font.bold: true
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
            
            Text {
                visible: root.subtitle !== ""
                text: root.subtitle
                color: Theme.textSecondary
                font.pixelSize: Metrics.fontCaption
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }
}
