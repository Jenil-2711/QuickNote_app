import SwiftUI

/// The user's chosen quick-capture shortcut. Changing it takes effect immediately and is remembered.
@MainActor
final class ShortcutSettings: ObservableObject {
    static let shared = ShortcutSettings()

    @Published private(set) var shortcut: Shortcut
    /// A short explanation shown in Settings when a shortcut could not be used.
    @Published var message: String?

    private init() {
        shortcut = Shortcut.load()
    }

    var display: String { shortcut.display }

    /// Registers the saved shortcut when the app starts.
    func applyAtLaunch() {
        if !HotKeyManager.shared.register(shortcut) {
            message = "\(shortcut.display) is used by another app. Choose a different shortcut."
        }
    }

    /// Tries `new` as the global shortcut. If it can't be used, the old one stays active.
    func change(to new: Shortcut) {
        guard new.isAcceptable else {
            message = "Use at least one of ⌃ ⌥ ⌘ together with a key, or a function key."
            resumeHotKey()
            return
        }
        if HotKeyManager.shared.register(new) {
            shortcut = new
            new.save()
            message = nil
        } else {
            message = "\(new.display) is already used by another app. Try a different one."
            resumeHotKey()
        }
    }

    func resetToDefault() {
        change(to: .defaultShortcut)
    }

    /// Called while recording: stops the current shortcut from firing so it can be re-pressed.
    func suspendHotKey() {
        HotKeyManager.shared.unregister()
    }

    /// Turns the current shortcut back on (after a cancelled or failed recording).
    func resumeHotKey() {
        HotKeyManager.shared.register(shortcut)
    }
}
