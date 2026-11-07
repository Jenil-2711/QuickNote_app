import XCTest
@testable import CozyQuickNoteDesk

private final class MemoryStore: NoteStoring {
    var saved: [Note] = []
    func load() throws -> [Note] { saved }
    func save(_ notes: [Note]) throws { saved = notes }
}

private final class FailingStore: NoteStoring {
    struct DiskFull: LocalizedError { var errorDescription: String? { "disk full" } }
    func load() throws -> [Note] { [] }
    func save(_ notes: [Note]) throws { throw DiskFull() }
}

@MainActor
final class NoteManagerTests: XCTestCase {

    func testAddingNoteSavesImmediately() {
        let store = MemoryStore()
        let manager = NoteManager(store: store, saveDelay: 60)
        manager.addNote(text: "idea", color: .peach)
        XCTAssertEqual(store.saved.map(\.text), ["idea"])
    }

    func testQuittingRightAfterTypingKeepsTheText() {
        let store = MemoryStore()
        let manager = NoteManager(store: store, saveDelay: 60)
        let note = manager.addNote(text: "a", color: .yellow)
        manager.updateText(id: note.id, text: "abc")
        XCTAssertEqual(store.saved.first?.text, "a")      // the half-second delay has not fired yet
        manager.saveNow()                                  // what happens on quit
        XCTAssertEqual(store.saved.first?.text, "abc")
    }

    func testFailingDiskKeepsTextAndShowsWarning() {
        let manager = NoteManager(store: FailingStore(), saveDelay: 60)
        manager.addNote(text: "still here", color: .lavender)
        XCTAssertEqual(manager.notes.first?.text, "still here")
        XCTAssertNotNil(manager.warning)
    }

    func testCompleteArchivesAndRestoreBringsItBack() {
        let manager = NoteManager(store: MemoryStore(), saveDelay: 60)
        let note = manager.addNote(text: "task", color: .cream)
        manager.complete(id: note.id)
        XCTAssertTrue(manager.activeNotes.isEmpty)
        XCTAssertEqual(manager.archivedNotes.first?.text, "task")
        XCTAssertNotNil(manager.archivedNotes.first?.completedAt)

        manager.restore(id: note.id)
        XCTAssertEqual(manager.activeNotes.count, 1)
        XCTAssertNil(manager.activeNotes.first?.completedAt)
    }

    func testTiltStaysWithinFourDegrees() {
        let manager = NoteManager(store: MemoryStore(), saveDelay: 60)
        for _ in 0..<50 { manager.addNote(text: "x", color: .pink) }
        XCTAssertTrue(manager.notes.allSatisfy { abs($0.tiltDegrees) <= Note.maxTilt })
    }

    func testNotesLandInsideTheBoard() {
        let manager = NoteManager(store: MemoryStore(), saveDelay: 60)
        for _ in 0..<40 { manager.addNote(text: "x", color: .sage) }
        XCTAssertTrue(manager.notes.allSatisfy {
            (0.0...1.0).contains($0.positionX) && (0.0...1.0).contains($0.positionY)
        })
    }

    func testDeleteRemovesPermanently() {
        let store = MemoryStore()
        let manager = NoteManager(store: store, saveDelay: 60)
        let note = manager.addNote(text: "bye", color: .sage)
        manager.delete(id: note.id)
        XCTAssertTrue(store.saved.isEmpty)
    }
}
