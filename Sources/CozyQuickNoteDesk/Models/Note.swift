import Foundation

/// One sticky note. Position is stored as a fraction (0...1) of the cork board so layouts
/// survive window resizing.
struct Note: Identifiable, Codable, Equatable {
    var id: UUID
    var text: String
    var color: NoteColor
    var design: NoteDesign
    var isCompleted: Bool
    var createdAt: Date
    var updatedAt: Date
    var completedAt: Date?
    var positionX: Double
    var positionY: Double
    var tiltDegrees: Double
    var displayOrder: Int

    /// Tilt is kept restrained so text stays readable.
    static let maxTilt = 4.0

    static func randomTilt() -> Double {
        Double.random(in: -maxTilt...maxTilt)
    }

    enum CodingKeys: String, CodingKey {
        case id, text, color, isCompleted, createdAt, updatedAt, completedAt
        case positionX, positionY, tiltDegrees, displayOrder
        case design = "shape"       // key name kept so notes saved by older versions still load
    }
}
