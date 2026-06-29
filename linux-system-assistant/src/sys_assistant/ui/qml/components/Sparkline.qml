import QtQuick
import "../styles"

Canvas {
    id: root

    property var values: []
    property color lineColor: Theme.accentBlue
    property color fillColor: Qt.rgba(lineColor.r, lineColor.g, lineColor.b, 0.1)
    property real maxValOverride: 0

    onValuesChanged: {
        requestPaint()
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        ctx.clearRect(0, 0, width, height)

        if (!values || values.length < 2)
            return

        // Find maximum value to normalize scale
        var maxVal = maxValOverride > 0 ? maxValOverride : 1.0
        if (maxValOverride <= 0) {
            for (var i = 0; i < values.length; i++) {
                if (values[i] > maxVal)
                    maxVal = values[i]
            }
        }

        var stepX = width / (values.length - 1)
        
        ctx.lineWidth = 1.5
        ctx.strokeStyle = lineColor
        ctx.fillStyle = fillColor

        // Begin line path
        ctx.beginPath()
        var firstY = height - ((values[0] / maxVal) * (height - 4) + 2)
        ctx.moveTo(0, firstY)

        for (var idx = 1; idx < values.length; idx++) {
            var x = idx * stepX
            var y = height - ((values[idx] / maxVal) * (height - 4) + 2)
            ctx.lineTo(x, y)
        }

        // Draw line
        ctx.stroke()

        // Close path at bottom to fill the area under the line
        ctx.lineTo(width, height)
        ctx.lineTo(0, height)
        ctx.closePath()
        ctx.fill()
    }
}
