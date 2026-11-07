import SwiftUI

/// The six pastel paper colours.
enum NoteColor: String, Codable, CaseIterable, Identifiable {
    case yellow, sage, peach, lavender, pink, cream

    var id: String { rawValue }

    var label: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .yellow:   return Color(red: 1.00, green: 0.90, blue: 0.56)
        case .sage:     return Color(red: 0.74, green: 0.86, blue: 0.64)
        case .peach:    return Color(red: 1.00, green: 0.78, blue: 0.64)
        case .lavender: return Color(red: 0.80, green: 0.74, blue: 0.94)
        case .pink:     return Color(red: 0.97, green: 0.72, blue: 0.82)
        case .cream:    return Color(red: 0.99, green: 0.95, blue: 0.85)
        }
    }
}
