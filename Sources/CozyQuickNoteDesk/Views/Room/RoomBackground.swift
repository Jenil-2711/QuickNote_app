import SwiftUI

/// Maps the room image onto the window using "fill" scaling, and finds where the cork board
/// ends up on screen so notes can be placed on it at any window size.
struct RoomGeometry {
    let size: CGSize

    var scale: CGFloat {
        max(size.width / RoomLayout.imageSize.width, size.height / RoomLayout.imageSize.height)
    }

    var origin: CGPoint {
        CGPoint(x: (size.width - RoomLayout.imageSize.width * scale) / 2,
                y: (size.height - RoomLayout.imageSize.height * scale) / 2)
    }

    /// The cork surface in window coordinates.
    var boardRect: CGRect {
        let img = RoomLayout.imageSize
        return CGRect(
            x: origin.x + RoomLayout.board.minX * img.width * scale,
            y: origin.y + RoomLayout.board.minY * img.height * scale,
            width: RoomLayout.board.width * img.width * scale,
            height: RoomLayout.board.height * img.height * scale
        )
    }

    /// A point given as fractions of the room image, in window coordinates.
    func point(fx: Double, fy: Double) -> CGPoint {
        let img = RoomLayout.imageSize
        return CGPoint(x: origin.x + CGFloat(fx) * img.width * scale,
                       y: origin.y + CGFloat(fy) * img.height * scale)
    }
}

/// The study room behind everything. Optionally dimmed and blurred so panels can sit on top of it.
struct RoomBackground: View {
    var showLights: Bool = true
    var dim: Double = 0
    var blur: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let image = AppResources.image("room") {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .blur(radius: blur)
                        .clipped()
                } else {
                    LinearGradient(
                        colors: [Color(red: 0.93, green: 0.85, blue: 0.70), Color(red: 0.62, green: 0.44, blue: 0.28)],
                        startPoint: .top, endPoint: .bottom)
                }
                if showLights {
                    TwinklingLights(room: RoomGeometry(size: geo.size))
                }
                Color.black.opacity(dim)
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
        }
        .allowsHitTesting(false)
    }
}

/// A soft glow over each real bulb in the picture, each twinkling at its own pace.
struct TwinklingLights: View {
    let room: RoomGeometry

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20.0)) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                let warm = Color(red: 1.0, green: 0.86, blue: 0.58)
                context.blendMode = .plusLighter

                for (i, p) in FairyLightPoints.all.enumerated() {
                    let center = room.point(fx: p.x, fy: p.y)
                    guard center.x > -20, center.x < size.width + 20,
                          center.y > -20, center.y < size.height + 20 else { continue }

                    let speed = 1.1 + Double(i % 5) * 0.23
                    let twinkle = 0.5 + 0.5 * sin(t * speed + Double(i) * 1.7)
                    let radius = (9.0 + CGFloat(i % 3) * 3.0) * max(0.8, room.scale * 1.1)

                    context.fill(
                        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius,
                                               width: radius * 2, height: radius * 2)),
                        with: .radialGradient(
                            Gradient(colors: [warm.opacity(0.55 * twinkle), warm.opacity(0)]),
                            center: center, startRadius: 0, endRadius: radius
                        )
                    )
                }
            }
        }
    }
}
