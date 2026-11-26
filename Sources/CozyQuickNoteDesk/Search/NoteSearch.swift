import Foundation

/// Finds notes by what they say. Case, accents and extra spaces do not matter, and every word
/// you type must appear somewhere in the note. Notes on the board come before archived ones,
/// and newer edits come first.
enum NoteSearch {
    static func results(for query: String, in notes: [Note], limit: Int = 8) -> [Note] {
        let words = normalize(query).split(separator: " ").map(String.init)

        let candidates = notes
            .filter { !$0.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .sorted { a, b in
                if a.isCompleted != b.isCompleted { return !a.isCompleted }
                return a.updatedAt > b.updatedAt
            }

        let matches = words.isEmpty
            ? candidates
            : candidates.filter { note in
                let text = normalize(note.text)
                return words.allSatisfy { text.contains($0) }
            }
        return Array(matches.prefix(limit))
    }

    static func normalize(_ text: String) -> String {
        text.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
