import SwiftUI

/// The app's "brain": holds the notes while the app runs and decides when to save.
/// The board window and the quick-capture leaf both share this one instance.
@MainActor
final class NoteManager: ObservableObject {
    static let shared = NoteManager()

    @Published private(set) var notes: [Note] = []
    /// Shown as a warning tag on the board when loading or saving fails.
    @Published var warning: String?

    private let store: NoteStoring
    private let saveDelay: TimeInterval
    private var pendingSave: Task<Void, Never>?

    init(store: NoteStoring = JSONNoteStore(), saveDelay: TimeInterval = 0.5) {
        self.store = store
        self.saveDelay = saveDelay
        do {
            notes = try store.load()
        } catch {
            warning = error.localizedDescription
        }
    }

    // MARK: - Reading

    var activeNotes: [Note] {
        notes.filter { !$0.isCompleted }.sorted { $0.displayOrder < $1.displayOrder }
    }

    var archivedNotes: [Note] {
        notes.filter { $0.isCompleted }.sorted {
            ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast)
        }
    }

    // MARK: - Changing notes

    @discardableResult
    func addNote(text: String, color: NoteColor, design: NoteDesign = NoteDesign.random()) -> Note {
        let spot = NotePlacement.freeSpot(avoiding: activeNotes.map {
            CGPoint(x: $0.positionX, y: $0.positionY)
        })
        let now = Date()
        let note = Note(
            id: UUID(), text: text, color: color, design: design,
            isCompleted: false, createdAt: now, updatedAt: now, completedAt: nil,
            positionX: spot.x, positionY: spot.y,
            tiltDegrees: Note.randomTilt(),
            displayOrder: nextDisplayOrder()
        )
        notes.append(note)
        saveNow()                      // adding is saved immediately
        return note
    }

    func updateText(id: UUID, text: String) {
        guard let i = index(of: id), notes[i].text != text else { return }
        notes[i].text = text
        notes[i].updatedAt = Date()
        scheduleSave()                 // edits are saved ~0.5 s after you stop typing
    }

    func updateColor(id: UUID, color: NoteColor) {
        guard let i = index(of: id), notes[i].color != color else { return }
        notes[i].color = color
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func move(id: UUID, toX x: Double, y: Double) {
        guard let i = index(of: id) else { return }
        notes[i].positionX = x
        notes[i].positionY = y
        notes[i].updatedAt = Date()
        scheduleSave()
    }

    func bringToFront(id: UUID) {
        guard let i = index(of: id), notes[i].displayOrder != maxDisplayOrder() else { return }
        notes[i].displayOrder = nextDisplayOrder()
        scheduleSave()
    }

    /// Completing never deletes: the note moves into the archive with its original data.
    func complete(id: UUID) {
        guard let i = index(of: id) else { return }
        notes[i].isCompleted = true
        notes[i].completedAt = Date()
        saveNow()
    }

    /// Pins an archived note back on the board, unchecked and editable again.
    func restore(id: UUID) {
        guard let i = index(of: id) else { return }
        let spot = NotePlacement.freeSpot(avoiding: activeNotes.map {
            CGPoint(x: $0.positionX, y: $0.positionY)
        })
        notes[i].isCompleted = false
        notes[i].completedAt = nil
        notes[i].positionX = spot.x
        notes[i].positionY = spot.y
        notes[i].displayOrder = nextDisplayOrder()
        saveNow()
    }

    func delete(id: UUID) {
        notes.removeAll { $0.id == id }
        saveNow()                      // deleting is saved immediately
    }

    /// Permanently removes every archived (completed) note in one go and returns how many were removed.
    @discardableResult
    func deleteAllArchived() -> Int {
        let count = notes.filter { $0.isCompleted }.count
        guard count > 0 else { return 0 }
        notes.removeAll { $0.isCompleted }
        saveNow()
        return count
    }

    // MARK: - Saving

    private func scheduleSave() {
        pendingSave?.cancel()
        let delay = saveDelay
        pendingSave = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.saveNow()
        }
    }

    /// Writes right now. If it fails, the text stays in the app, a warning appears,
    /// and the next change tries again.
    func saveNow() {
        pendingSave?.cancel()
        pendingSave = nil
        do {
            try store.save(notes)
            warning = nil
        } catch {
            warning = "Couldn't save your notes (\(error.localizedDescription)). Your text is still here and will be saved again on your next change."
        }
    }

    // MARK: - Helpers

    private func index(of id: UUID) -> Int? {
        notes.firstIndex { $0.id == id }
    }

    private func maxDisplayOrder() -> Int {
        notes.map(\.displayOrder).max() ?? 0
    }

    private func nextDisplayOrder() -> Int {
        maxDisplayOrder() + 1
    }
}
