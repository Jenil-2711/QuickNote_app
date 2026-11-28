import XCTest
@testable import CozyQuickNoteDesk

final class NoteGrowthTests: XCTestCase {
    private let side: CGFloat = 150
    private let longText = String(repeating: "Remember to revise the operating systems chapter and push the project to GitHub. ", count: 4)

    func testShortTextDoesNotGrow() {
        let scale = NoteGrowth.scale(text: "Buy pens", design: .spiralBear, side: side, fontSize: 15, maxScale: 2)
        XCTAssertEqual(scale, 1, accuracy: 0.0001)
    }

    func testEmptyTextDoesNotGrow() {
        XCTAssertEqual(NoteGrowth.scale(text: "", design: .tapedBear, side: side, fontSize: 15, maxScale: 2), 1, accuracy: 0.0001)
    }

    func testLongTextGrowsButStaysWithinTheLimit() {
        let scale = NoteGrowth.scale(text: longText, design: .spiralBear, side: side, fontSize: 15, maxScale: 2)
        XCTAssertGreaterThan(scale, 1)
        XCTAssertLessThanOrEqual(scale, 2.0001)
    }

    func testMoreTextNeverMeansASmallerNote() {
        let medium = NoteGrowth.scale(text: String(longText.prefix(120)), design: .spiralBear, side: side, fontSize: 15, maxScale: 2.2)
        let large = NoteGrowth.scale(text: longText, design: .spiralBear, side: side, fontSize: 15, maxScale: 2.2)
        XCTAssertGreaterThanOrEqual(large, medium)
    }

    func testBiggerLettersNeedABiggerNote() {
        let small = NoteGrowth.scale(text: longText, design: .tornCupcake, side: side, fontSize: 13, maxScale: 2.2)
        let big = NoteGrowth.scale(text: longText, design: .tornCupcake, side: side, fontSize: 20, maxScale: 2.2)
        XCTAssertGreaterThanOrEqual(big, small)
    }

    func testNoGrowthAllowedMeansNoGrowth() {
        XCTAssertEqual(NoteGrowth.scale(text: longText, design: .spiralBear, side: side, fontSize: 15, maxScale: 1), 1, accuracy: 0.0001)
    }

    func testHugeTextStopsAtTheLimit() {
        let huge = String(repeating: longText, count: 6)
        XCTAssertEqual(NoteGrowth.scale(text: huge, design: .ringBinder, side: side, fontSize: 15, maxScale: 1.8), 1.8, accuracy: 0.06)
    }
}
