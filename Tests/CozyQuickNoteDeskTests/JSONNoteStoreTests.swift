import XCTest
@testable import CozyQuickNoteDesk

final class JSONNoteStoreTests: XCTestCase {
    private var directory: URL!

    override func setUp() {
        super.setUp()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: directory)
        super.tearDown()
    }

    private func sampleNote(_ text: String) -> Note {
        let now = Date()
        return Note(id: UUID(), text: text, color: .sage, shape: .heart, isCompleted: false,
                    createdAt: now, updatedAt: now, completedAt: nil,
                    positionX: 0.4, positionY: 0.6, tiltDegrees: 2.5, displayOrder: 1)
    }

    func testMissingFileLoadsEmpty() throws {
        XCTAssertEqual(try JSONNoteStore(directory: directory).load(), [])
    }

    func testSaveThenLoadKeepsEverything() throws {
        let store = JSONNoteStore(directory: directory)
        let note = sampleNote("remember the milk")
        try store.save([note])
        let loaded = try JSONNoteStore(directory: directory).load()
        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded[0].text, note.text)
        XCTAssertEqual(loaded[0].color, .sage)
        XCTAssertEqual(loaded[0].shape, .heart)
        XCTAssertEqual(loaded[0].tiltDegrees, 2.5, accuracy: 0.0001)
    }

    func testDamagedFileIsSetAsideNotDeleted() throws {
        let store = JSONNoteStore(directory: directory)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try Data("this is not json".utf8).write(to: store.fileURL)

        XCTAssertThrowsError(try store.load())
        XCTAssertFalse(FileManager.default.fileExists(atPath: store.fileURL.path))
        let files = try FileManager.default.contentsOfDirectory(atPath: directory.path)
        XCTAssertTrue(files.contains { $0.hasPrefix("notes.damaged-") })
    }
}
