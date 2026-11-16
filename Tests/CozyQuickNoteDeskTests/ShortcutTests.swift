import XCTest
import Carbon.HIToolbox
@testable import CozyQuickNoteDesk

final class ShortcutTests: XCTestCase {

    func testDefaultShortcutIsControlOptionN() {
        XCTAssertEqual(Shortcut.defaultShortcut.display, "⌃⌥N")
    }

    func testModifiersAreShownInTheStandardMacOrder() {
        let all = Shortcut(keyCode: UInt32(kVK_ANSI_K),
                           modifiers: UInt32(cmdKey | shiftKey | optionKey | controlKey),
                           keyLabel: "K")
        XCTAssertEqual(all.display, "⌃⌥⇧⌘K")
    }

    func testNeedsControlOptionOrCommandUnlessItIsAFunctionKey() {
        let shiftOnly = Shortcut(keyCode: UInt32(kVK_ANSI_N), modifiers: UInt32(shiftKey), keyLabel: "N")
        let bare = Shortcut(keyCode: UInt32(kVK_ANSI_N), modifiers: 0, keyLabel: "N")
        let command = Shortcut(keyCode: UInt32(kVK_ANSI_N), modifiers: UInt32(cmdKey | shiftKey), keyLabel: "N")
        let function = Shortcut(keyCode: UInt32(kVK_F5), modifiers: 0, keyLabel: "F5")

        XCTAssertFalse(shiftOnly.isAcceptable)
        XCTAssertFalse(bare.isAcceptable)
        XCTAssertTrue(command.isAcceptable)
        XCTAssertTrue(function.isAcceptable)
    }

    func testSavedShortcutLoadsBack() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "ShortcutTests-\(UUID().uuidString)"))
        XCTAssertEqual(Shortcut.load(from: defaults), Shortcut.defaultShortcut)    // nothing saved yet

        let custom = Shortcut(keyCode: UInt32(kVK_Space), modifiers: UInt32(cmdKey | optionKey), keyLabel: "Space")
        custom.save(to: defaults)
        XCTAssertEqual(Shortcut.load(from: defaults), custom)
    }

    func testAnUnusableSavedShortcutFallsBackToTheDefault() throws {
        let defaults = try XCTUnwrap(UserDefaults(suiteName: "ShortcutTests-\(UUID().uuidString)"))
        Shortcut(keyCode: UInt32(kVK_ANSI_A), modifiers: 0, keyLabel: "A").save(to: defaults)
        XCTAssertEqual(Shortcut.load(from: defaults), Shortcut.defaultShortcut)
    }
}
