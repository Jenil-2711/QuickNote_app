import XCTest
@testable import CozyQuickNoteDesk

final class NoteSearchTests: XCTestCase {

    private func note(_ text: String, completed: Bool = false, minutesAgo: Double = 0) -> Note {
        let when = Date().addingTimeInterval(-minutesAgo * 60)
        return Note(id: UUID(), text: text, color: .sage, design: .spiralBear, isCompleted: completed,
                    createdAt: when, updatedAt: when, completedAt: completed ? when : nil,
                    positionX: 0.5, positionY: 0.5, tiltDegrees: 0, displayOrder: 1)
    }

    func testIgnoresCaseAndAccents() {
        let notes = [note("Buy Café supplies"), note("Call mom")]
        XCTAssertEqual(NoteSearch.results(for: "cafe", in: notes).map(\.text), ["Buy Café supplies"])
        XCTAssertEqual(NoteSearch.results(for: "CALL", in: notes).map(\.text), ["Call mom"])
    }

    func testEveryWordMustAppear() {
        let notes = [note("Revise OS chapter 7"), note("Revise maths"), note("OS lab report")]
        XCTAssertEqual(NoteSearch.results(for: "os revise", in: notes).map(\.text), ["Revise OS chapter 7"])
    }

    func testEmptyQueryShowsRecentNotesAndSkipsBlankOnes() {
        let notes = [note("older", minutesAgo: 30), note("   "), note("newer", minutesAgo: 1)]
        XCTAssertEqual(NoteSearch.results(for: "", in: notes).map(\.text), ["newer", "older"])
    }

    func testBoardNotesComeBeforeArchivedOnes() {
        let notes = [note("exam plan archived", completed: true, minutesAgo: 1), note("exam plan", minutesAgo: 60)]
        XCTAssertEqual(NoteSearch.results(for: "exam", in: notes).map(\.text), ["exam plan", "exam plan archived"])
    }

    func testLimitsTheNumberOfResults() {
        let notes = (0..<20).map { note("idea \($0)", minutesAgo: Double($0)) }
        XCTAssertEqual(NoteSearch.results(for: "idea", in: notes, limit: 5).count, 5)
    }

    func testNoMatchReturnsNothing() {
        XCTAssertTrue(NoteSearch.results(for: "zebra", in: [note("apple")]).isEmpty)
    }
}
