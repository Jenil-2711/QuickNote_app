import SwiftUI
import Carbon.HIToolbox

/// The app's two global shortcuts.
enum ShortcutAction {
    case capture      // opens the leaf
    case search       // opens the note search

    var hotKeyID: UInt32 {
        switch self {
        case .capture: return 1
        case .search:  return 2
        }
    }

    var storageKey: String {
        switch self {
        case .capture: return "quickCaptureShortcut"
        case .search:  return "searchShortcut"
        }
    }

    var title: String {
        switch self {
        case .capture: return "Quick capture"
        case .search:  return "Search notes"
        }
    }

    var defaultShortcut: Shortcut {
        switch self {
        case .capture:
            return Shortcut.defaultShortcut                       // Control + Option + N
        case .search:
            return Shortcut(keyCode: UInt32(kVK_ANSI_F),          // Control + Option + F
                            modifiers: UInt32(controlKey | optionKey), keyLabel: "F")
        }
    }
}

/// One shortcut the user can change. Changing it takes effect immediately and is remembered.
@MainActor
final class ShortcutSettings: ObservableObject {
    static let capture = ShortcutSettings(action: .capture)
    static let search = ShortcutSettings(action: .search)

    /// The quick-capture shortcut (kept so older call sites still work).
    static var shared: ShortcutSettings { capture }

    let action: ShortcutAction

    @Published private(set) var shortcut: Shortcut
    /// A short explanation shown in Settings when a shortcut could not be used.
    @Published var message: String?

    private init(action: ShortcutAction) {
        self.action = action
        shortcut = Shortcut.load(key: action.storageKey, fallback: action.defaultShortcut)
    }

    var display: String { shortcut.display }

    /// Registers the saved shortcut when the app starts.
    func applyAtLaunch() {
        if !HotKeyManager.shared.register(shortcut, id: action.hotKeyID) {
            message = "\(shortcut.display) is already in use. Choose a different shortcut."
        }
    }

    /// Tries `new` as this shortcut. If it can't be used, the old one stays active.
    func change(to new: Shortcut) {
        guard new.isAcceptable else {
            message = "Use at least one of ⌃ ⌥ ⌘ together with a key, or a function key."
            Self.resumeAll()
            return
        }
        Self.resumeAll()                                          // both current shortcuts are on again
        let previous = shortcut
        if HotKeyManager.shared.register(new, id: action.hotKeyID) {
            shortcut = new
            new.save(key: action.storageKey)
            message = nil
        } else {
            message = "\(new.display) is already used by another app or by your other shortcut. Try a different one."
            HotKeyManager.shared.register(previous, id: action.hotKeyID)
        }
    }

    func resetToDefault() {
        change(to: action.defaultShortcut)
    }

    /// Turns this shortcut back on (used after a cancelled recording).
    func resumeHotKey() {
        HotKeyManager.shared.register(shortcut, id: action.hotKeyID)
    }

    // MARK: - Both shortcuts at once

    /// While a new shortcut is being recorded, both are switched off, so pressing either one records it.
    static func suspendAll() {
        HotKeyManager.shared.unregister(id: ShortcutAction.capture.hotKeyID)
        HotKeyManager.shared.unregister(id: ShortcutAction.search.hotKeyID)
    }

    static func resumeAll() {
        capture.resumeHotKey()
        search.resumeHotKey()
    }
}
