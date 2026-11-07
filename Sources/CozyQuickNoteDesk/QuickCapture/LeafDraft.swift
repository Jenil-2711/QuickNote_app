import Foundation

/// Keeps whatever you typed in the leaf, so closing the popup never throws it away.
enum LeafDraft {
    private static let textKey = "leafDraft.text"
    private static let colorKey = "leafDraft.color"

    static var text: String {
        get { UserDefaults.standard.string(forKey: textKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: textKey) }
    }

    static var color: NoteColor {
        get { NoteColor(rawValue: UserDefaults.standard.string(forKey: colorKey) ?? "") ?? .yellow }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: colorKey) }
    }

    static func clearText() {
        UserDefaults.standard.removeObject(forKey: textKey)
    }
}
