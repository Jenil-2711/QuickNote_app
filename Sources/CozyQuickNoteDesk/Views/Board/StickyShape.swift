import SwiftUI

/// Draws the silhouette of a note. Corners are softened by also stroking the shape with a round join.
struct StickyShape: Shape {
    let kind: NoteShape

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: 5, dy: 5)
        func P(_ x: Double, _ y: Double) -> CGPoint {
            CGPoint(x: r.minX + CGFloat(x) * r.width, y: r.minY + CGFloat(y) * r.height)
        }
        func E(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> CGRect {
            CGRect(x: r.minX + CGFloat(x) * r.width, y: r.minY + CGFloat(y) * r.height,
                   width: CGFloat(w) * r.width, height: CGFloat(h) * r.height)
        }

        var p = Path()
        switch kind {
        case .square:
            p.addRoundedRect(in: r, cornerSize: CGSize(width: 3, height: 3))

        case .heart:
            p.move(to: P(0.5, 0.95))
            p.addCurve(to: P(0.04, 0.33), control1: P(0.20, 0.80), control2: P(0.04, 0.55))
            p.addCurve(to: P(0.5, 0.25), control1: P(0.04, 0.08), control2: P(0.40, 0.05))
            p.addCurve(to: P(0.96, 0.33), control1: P(0.60, 0.05), control2: P(0.96, 0.08))
            p.addCurve(to: P(0.5, 0.95), control1: P(0.96, 0.55), control2: P(0.80, 0.80))
            p.closeSubpath()

        case .star:
            for i in 0..<10 {
                let angle = -Double.pi / 2 + Double(i) * Double.pi / 5
                let radius = i % 2 == 0 ? 0.50 : 0.23
                let pt = P(0.5 + radius * cos(angle), 0.53 + radius * sin(angle))
                if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
            }
            p.closeSubpath()

        case .apple:
            p.move(to: P(0.5, 0.20))
            p.addCurve(to: P(0.06, 0.50), control1: P(0.35, 0.08), control2: P(0.06, 0.25))
            p.addCurve(to: P(0.5, 0.93), control1: P(0.06, 0.78), control2: P(0.30, 0.98))
            p.addCurve(to: P(0.94, 0.50), control1: P(0.70, 0.98), control2: P(0.94, 0.78))
            p.addCurve(to: P(0.5, 0.20), control1: P(0.94, 0.25), control2: P(0.65, 0.08))
            p.closeSubpath()
            p.addRoundedRect(in: E(0.46, 0.02, 0.08, 0.20), cornerSize: CGSize(width: 2, height: 2))

        case .strawberry:
            p.move(to: P(0.5, 0.10))
            p.addCurve(to: P(0.95, 0.45), control1: P(0.80, 0.10), control2: P(0.97, 0.25))
            p.addCurve(to: P(0.5, 0.92), control1: P(0.93, 0.70), control2: P(0.70, 0.88))
            p.addCurve(to: P(0.05, 0.45), control1: P(0.30, 0.88), control2: P(0.07, 0.70))
            p.addCurve(to: P(0.5, 0.10), control1: P(0.03, 0.25), control2: P(0.20, 0.10))
            p.closeSubpath()
            p.addRoundedRect(in: E(0.44, 0.90, 0.12, 0.10), cornerSize: CGSize(width: 2, height: 2))

        case .tree:
            let pts: [(Double, Double)] = [
                (0.50, 0.00), (0.78, 0.32), (0.66, 0.32), (0.88, 0.62), (0.72, 0.62),
                (0.98, 0.90), (0.58, 0.90), (0.58, 1.00), (0.42, 1.00), (0.42, 0.90),
                (0.02, 0.90), (0.28, 0.62), (0.12, 0.62), (0.34, 0.32), (0.22, 0.32)
            ]
            for (i, pt) in pts.enumerated() {
                if i == 0 { p.move(to: P(pt.0, pt.1)) } else { p.addLine(to: P(pt.0, pt.1)) }
            }
            p.closeSubpath()

        case .bear:
            p.addEllipse(in: E(0.10, 0.02, 0.28, 0.28))   // ears
            p.addEllipse(in: E(0.62, 0.02, 0.28, 0.28))
            p.addEllipse(in: E(0.16, 0.08, 0.68, 0.52))   // head
            p.addEllipse(in: E(0.10, 0.42, 0.80, 0.52))   // body
            p.addEllipse(in: E(0.06, 0.78, 0.30, 0.20))   // feet
            p.addEllipse(in: E(0.64, 0.78, 0.30, 0.20))
        }
        return p
    }
}
