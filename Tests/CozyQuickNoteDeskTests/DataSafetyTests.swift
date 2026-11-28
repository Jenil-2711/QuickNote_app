import XCTest
@testable import CozyQuickNoteDesk

/// What happens to people's notes when something goes wrong: a folder that cannot be written,
/// a damaged file, a file written by an older version, an app that quits before its delayed save.
@MainActor
final class DataSafetyTests: XCTestCase {

    private func makeDirectory() -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("cozy-tests-\(UUID().uuidString)")
        addTeardownBlock {
            try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
            try? FileManager.default.removeItem(at: directory)
        }
        return directory
    }

    func testSavingIntoAReadOnlyFolderKeepsTheTextAndRetriesOnTheNextChange() throws {
        try XCTSkipIf(getuid() == 0, "the root user can write anywhere")
        let directory = makeDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try FileManager.default.setAttributes([.posixPermissions: 0o500], ofItemAtPath: directory.path)

        let manager = NoteManager(store: JSONNoteStore(directory: directory), saveDelay: 60)
        let note = manager.addNote(text: "keep me", color: .sage)
        XCTAssertNotNil(manager.warning)                              // the user is told
        XCTAssertEqual(manager.notes.first?.text, "keep me")          // and the text is not lost

        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: directory.path)
        manager.updateText(id: note.id, text: "keep me, edited")
        manager.saveNow()                                             // the next change tries again
        XCTAssertNil(manager.warning)
        XCTAssertEqual(try JSONNoteStore(directory: directory).load().first?.text, "keep me, edited")
    }

    func testADamagedFileIsSetAsideAndTheAppStartsEmptyAndWorking() throws {
        let directory = makeDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("{ not valid".utf8).write(to: directory.appendingPathComponent("notes.json"))

        let manager = NoteManager(store: JSONNoteStore(directory: directory), saveDelay: 60)
        XCTAssertTrue(manager.notes.isEmpty)
        XCTAssertNotNil(manager.warning)

        let names = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        XCTAssertTrue(names.contains { $0.hasPrefix("notes.damaged-") })   // kept, never deleted
        XCTAssertFalse(names.contains("notes.json"))

        manager.addNote(text: "a fresh start", color: .peach)
        XCTAssertNil(manager.warning)
        XCTAssertEqual(try JSONNoteStore(directory: directory).load().count, 1)
    }

    func testNotesWrittenByVersion1StillLoad() throws {
        let directory = makeDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let json = """
        {"version":1,"notes":[{"id":"\(UUID().uuidString)","text":"Written by 1.0.0","color":"peach",
        "shape":"tapePad","isCompleted":true,"createdAt":"2026-11-20T10:00:00Z","updatedAt":"2026-11-20T10:05:00Z",
        "completedAt":"2026-11-21T09:00:00Z","positionX":0.3,"positionY":0.6,"tiltDegrees":-2,"displayOrder":4}]}
        """
        try Data(json.utf8).write(to: directory.appendingPathComponent("notes.json"))

        let loaded = try JSONNoteStore(directory: directory).load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].text, "Written by 1.0.0")
        XCTAssertEqual(loaded[0].design, .tapePad)
        XCTAssertEqual(loaded[0].color, .peach)
        XCTAssertTrue(loaded[0].isCompleted)
        XCTAssertNotNil(loaded[0].completedAt)
        XCTAssertEqual(loaded[0].positionX, 0.3, accuracy: 0.0001)
    }

    func testUnknownDesignsAndExtraFieldsFromAFutureVersionAreTolerated() throws {
        let directory = makeDirectory()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let json = """
        {"version":2,"notes":[{"id":"\(UUID().uuidString)","text":"from the future","color":"sage",
        "shape":"a-design-that-does-not-exist","pinned":true,"isCompleted":false,
        "createdAt":"2026-12-01T10:00:00Z","updatedAt":"2026-12-01T10:00:00Z",
        "positionX":0.5,"positionY":0.5,"tiltDegrees":1,"displayOrder":1}]}
        """
        try Data(json.utf8).write(to: directory.appendingPathComponent("notes.json"))

        let loaded = try JSONNoteStore(directory: directory).load()
        XCTAssertEqual(loaded.first?.text, "from the future")
        XCTAssertTrue(NoteDesign.allCases.contains(loaded[0].design))
    }

    func testSavingLeavesNoTemporaryFilesBehind() throws {
        let directory = makeDirectory()
        let store = JSONNoteStore(directory: directory)
        let manager = NoteManager(store: store, saveDelay: 60)
        manager.addNote(text: "one", color: .yellow)
        manager.addNote(text: "two", color: .pink)
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: directory.path), ["notes.json"])
    }

    func testEditsAreSavedByThemselvesAfterTheDelay() async throws {
        let directory = makeDirectory()
        let store = JSONNoteStore(directory: directory)
        let manager = NoteManager(store: store, saveDelay: 0.05)
        let note = manager.addNote(text: "first", color: .yellow)
        manager.updateText(id: note.id, text: "second")

        try await Task.sleep(nanoseconds: 600_000_000)                // no quit, no explicit save
        XCTAssertEqual(try store.load().first?.text, "second")
    }
}
