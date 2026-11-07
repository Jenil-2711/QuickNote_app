import SwiftUI

/// The study room's palette and fonts: cream and beige paper, walnut and oak wood,
/// sage leaves, terracotta pots. Every screen uses these so the app feels like one place.
enum Theme {
    static let cream      = Color(red: 0.96, green: 0.92, blue: 0.84)
    static let beige      = Color(red: 0.89, green: 0.82, blue: 0.69)
    static let walnut     = Color(red: 0.30, green: 0.19, blue: 0.11)
    static let oak        = Color(red: 0.62, green: 0.45, blue: 0.28)
    static let sage       = Color(red: 0.38, green: 0.50, blue: 0.34)
    static let terracotta = Color(red: 0.70, green: 0.36, blue: 0.25)
    static let ink        = Color(red: 0.23, green: 0.15, blue: 0.09)

    static func serif(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }

    /// Handwriting-style font (falls back to the system font if Noteworthy is missing).
    static func hand(_ size: CGFloat) -> Font {
        .custom("Noteworthy", size: size)
    }
}
