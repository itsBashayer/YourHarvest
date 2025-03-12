
import SwiftUI

struct CircleCutoutShape: Shape {
    var cornerRadius: CGFloat = 20
    var holeRadius: CGFloat = 20

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midX = rect.midX

        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(270),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: midX - holeRadius, y: 0))
        path.addArc(
            center: CGPoint(x: midX, y: 0),
            radius: holeRadius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: w - cornerRadius, y: 0))
        path.addArc(
            center: CGPoint(x: w - cornerRadius, y: cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(270),
            endAngle: .degrees(360),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: w, y: h - cornerRadius))
        path.addArc(
            center: CGPoint(x: w - cornerRadius, y: h - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: cornerRadius, y: h))
        path.addArc(
            center: CGPoint(x: cornerRadius, y: h - cornerRadius),
            radius: cornerRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: 0, y: cornerRadius))
        return path
    }
}
