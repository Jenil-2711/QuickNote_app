import Foundation

/// The eight stationery designs a sticky note can have. A new note gets one at random.
/// The artwork lives in Resources/note_<name>_paper.png and note_<name>_deco.png
/// (drawn by scripts/generate_notes.py); the writing area of each is in NoteDesignLayout.swift.
enum NoteDesign: String, Codable, CaseIterable {
    case scallopChecklist   // stamp-edged paper, round check circles, tiny bear
    case spiralBear         // spiral notebook page with a sitting bear
    case tapedBear          // double-bordered page held by washi tape, bear with a heart
    case bowChecklist       // perforated top, chocolate bow, checkboxes
    case ringBinder         // rounded page with binder rings and gingerbread cookies
    case tapePad            // lined pad over a peach sheet, brown tape, chocolate-chip cookie
    case spiralTab          // spiral page with a brown tab and a gingerbread man
    case tornCupcake        // torn-edge page with a chocolate cupcake

    /// Multiplier applied to the base note size.
    var sizeScale: Double { 1.08 }

    static func random() -> NoteDesign {
        allCases.randomElement() ?? .spiralBear
    }

    /// Notes saved by earlier versions used other shape names. They are mapped to a design
    /// so those files still load instead of being treated as damaged.
    private static let legacyNames: [String: NoteDesign] = [
        "square": .spiralBear, "heart": .tapedBear, "star": .ringBinder, "apple": .tapePad,
        "strawberry": .bowChecklist, "tree": .scallopChecklist, "bear": .tornCupcake
    ]

    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = NoteDesign(rawValue: raw) ?? NoteDesign.legacyNames[raw] ?? .spiralBear
    }
}
