import SwiftUI

/// Dark walnut planks, used for the top bar, frames and headers.
struct WoodSurface: View {
    var body: some View {
        GeometryReader { geo in
            if let image = AppResources.image("wood") {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            } else {
                Theme.walnut
            }
        }
    }
}

/// Cream paper with a fine fibre texture, used for cards, panels and sticky notes.
struct PaperSurface: View {
    var tint: Color = Theme.cream
    var textureOpacity: Double = 0.55

    var body: some View {
        ZStack {
            tint
            if let image = AppResources.image("paper") {
                Image(nsImage: image)
                    .resizable(resizingMode: .tile)
                    .blendMode(.multiply)
                    .opacity(textureOpacity)
            }
        }
    }
}

/// A raised pill button in paper, sage or terracotta.
struct CozyButtonStyle: ButtonStyle {
    enum Kind { case plain, primary, danger }
    var kind: Kind = .plain

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.serif(13))
            .foregroundColor(kind == .plain ? Theme.ink : Theme.cream)
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(Capsule().fill(fill))
            .overlay(Capsule().strokeBorder(Theme.walnut.opacity(0.5), lineWidth: 1))
            .shadow(color: .black.opacity(0.28), radius: 2, x: 0, y: 2)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
    }

    private var fill: Color {
        switch kind {
        case .plain:   return Theme.cream
        case .primary: return Theme.sage
        case .danger:  return Theme.terracotta
        }
    }
}

/// A small glossy push-pin, drawn in code.
struct PushPin: View {
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.black.opacity(0.35))
                .frame(width: 13, height: 13)
                .offset(x: 3, y: 4)
                .blur(radius: 2)
            Circle()
                .fill(RadialGradient(
                    colors: [color.opacity(0.85), color, color.opacity(0.55)],
                    center: UnitPoint(x: 0.35, y: 0.3), startRadius: 0, endRadius: 11))
                .frame(width: 15, height: 15)
            Circle()
                .fill(Color.white.opacity(0.75))
                .frame(width: 4, height: 4)
                .offset(x: -3, y: -3.5)
        }
    }
}
