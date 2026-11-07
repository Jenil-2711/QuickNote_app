import Foundation
import CoreGraphics

/// The silhouette of a sticky note on the board.
enum NoteShape: String, Codable, CaseIterable {
    case square, heart, star, apple, strawberry, tree, bear

    /// Multiplier applied to the base note size so every shape has a usable writing area.
    var sizeScale: Double {
        switch self {
        case .square:     return 1.00
        case .heart:      return 1.10
        case .star:       return 1.35
        case .apple:      return 1.05
        case .strawberry: return 1.05
        case .tree:       return 1.20
        case .bear:       return 1.15
        }
    }

    /// Where text may be written, as a fraction of the note's square frame.
    var textRect: CGRect {
        switch self {
        case .square:     return CGRect(x: 0.10, y: 0.14, width: 0.80, height: 0.76)
        case .heart:      return CGRect(x: 0.20, y: 0.30, width: 0.60, height: 0.46)
        case .star:       return CGRect(x: 0.28, y: 0.36, width: 0.44, height: 0.38)
        case .apple:      return CGRect(x: 0.15, y: 0.30, width: 0.70, height: 0.52)
        case .strawberry: return CGRect(x: 0.17, y: 0.24, width: 0.66, height: 0.52)
        case .tree:       return CGRect(x: 0.28, y: 0.40, width: 0.44, height: 0.44)
        case .bear:       return CGRect(x: 0.26, y: 0.28, width: 0.48, height: 0.44)
        }
    }

    /// Vertical position of the push-pin, as a fraction of the note's frame.
    var pinY: Double {
        switch self {
        case .square:     return 0.07
        case .heart:      return 0.26
        case .star:       return 0.14
        case .apple:      return 0.15
        case .strawberry: return 0.14
        case .tree:       return 0.07
        case .bear:       return 0.14
        }
    }

    /// Random shape for a new note. Square pads are the most common, like a real pinboard.
    static func random() -> NoteShape {
        let weighted: [NoteShape] = [
            .square, .square, .square, .square, .square,
            .heart, .apple, .strawberry, .bear, .star, .tree
        ]
        return weighted.randomElement() ?? .square
    }
}
