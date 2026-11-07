import Foundation
import CoreGraphics

/// Chooses where a new note lands on the cork board: random, but as far from
/// existing notes as possible, so the board looks naturally filled.
enum NotePlacement {
    static func freeSpot(avoiding existing: [CGPoint], attempts: Int = 80) -> CGPoint {
        var best = CGPoint(x: 0.5, y: 0.5)
        var bestDistance = -1.0
        for _ in 0..<attempts {
            let candidate = CGPoint(x: Double.random(in: 0.10...0.90),
                                    y: Double.random(in: 0.18...0.76))
            // x is stretched because the board is much wider than it is tall
            let nearest = existing
                .map { point -> Double in
                    let dx = Double(point.x - candidate.x) * RoomLayout.boardAspect
                    let dy = Double(point.y - candidate.y)
                    return (dx * dx + dy * dy).squareRoot()
                }
                .min() ?? 10.0
            if nearest > bestDistance {
                bestDistance = nearest
                best = candidate
            }
        }
        return best
    }
}
