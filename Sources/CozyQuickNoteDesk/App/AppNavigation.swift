import SwiftUI

enum RoomTab: String, CaseIterable, Identifiable {
    case board = "Board"
    case archive = "Archive"
    var id: String { rawValue }
}

/// Shared state for the room window: the current tab, and a note to draw attention to
/// (used when you open a note from search).
@MainActor
final class AppNavigation: ObservableObject {
    static let shared = AppNavigation()

    @Published var tab: RoomTab = .board
    @Published var highlightedNoteID: UUID?

    /// Jumps to a note: board notes get a glowing outline for a few seconds, archived notes open the Archive.
    func reveal(_ note: Note) {
        if note.isCompleted {
            tab = .archive
            highlightedNoteID = nil
            return
        }
        tab = .board
        highlightedNoteID = note.id
        NoteManager.shared.bringToFront(id: note.id)

        let id = note.id
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if self.highlightedNoteID == id { self.highlightedNoteID = nil }
        }
    }
}
