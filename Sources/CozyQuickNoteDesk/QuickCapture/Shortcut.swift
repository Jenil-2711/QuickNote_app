import AppKit
import Carbon.HIToolbox

/// A global keyboard shortcut: a key plus modifier keys. Saved in UserDefaults.
struct Shortcut: Codable, Equatable {
    var keyCode: UInt32
    /// Carbon modifier flags (controlKey, optionKey, shiftKey, cmdKey).
    var modifiers: UInt32
    /// What to show for the key, e.g. "N" or "Space".
    var keyLabel: String

    /// Control + Option + N
    static let defaultShortcut = Shortcut(
        keyCode: UInt32(kVK_ANSI_N),
        modifiers: UInt32(controlKey | optionKey),
        keyLabel: "N"
    )

    // MARK: - Display

    /// Modifier symbols in the standard Mac order, then the key: "⌃⌥N".
    var display: String { modifierSymbols + keyLabel }

    var modifierSymbols: String {
        var text = ""
        if modifiers & UInt32(controlKey) != 0 { text += "⌃" }
        if modifiers & UInt32(optionKey) != 0 { text += "⌥" }
        if modifiers & UInt32(shiftKey) != 0 { text += "⇧" }
        if modifiers & UInt32(cmdKey) != 0 { text += "⌘" }
        return text
    }

    // MARK: - Rules

    /// A shortcut must include Control, Option or Command (otherwise it would fire while typing),
    /// unless it is a function key such as F5.
    var isAcceptable: Bool {
        let strong = modifiers & UInt32(controlKey | optionKey | cmdKey) != 0
        return strong || Shortcut.functionKeyCodes.contains(Int(keyCode))
    }

    private static let functionKeyCodes: Set<Int> = [
        kVK_F1, kVK_F2, kVK_F3, kVK_F4, kVK_F5, kVK_F6, kVK_F7, kVK_F8, kVK_F9, kVK_F10,
        kVK_F11, kVK_F12, kVK_F13, kVK_F14, kVK_F15, kVK_F16, kVK_F17, kVK_F18, kVK_F19, kVK_F20
    ]

    // MARK: - Reading a key press

    static func from(event: NSEvent) -> Shortcut {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        var mods: UInt32 = 0
        if flags.contains(.control) { mods |= UInt32(controlKey) }
        if flags.contains(.option) { mods |= UInt32(optionKey) }
        if flags.contains(.shift) { mods |= UInt32(shiftKey) }
        if flags.contains(.command) { mods |= UInt32(cmdKey) }
        return Shortcut(keyCode: UInt32(event.keyCode), modifiers: mods, keyLabel: label(for: event))
    }

    private static let specialLabels: [Int: String] = [
        kVK_Space: "Space", kVK_Return: "↩", kVK_Tab: "⇥", kVK_Delete: "⌫", kVK_ForwardDelete: "⌦",
        kVK_Escape: "⎋", kVK_LeftArrow: "←", kVK_RightArrow: "→", kVK_UpArrow: "↑", kVK_DownArrow: "↓",
        kVK_Home: "↖", kVK_End: "↘", kVK_PageUp: "⇞", kVK_PageDown: "⇟",
        kVK_F1: "F1", kVK_F2: "F2", kVK_F3: "F3", kVK_F4: "F4", kVK_F5: "F5", kVK_F6: "F6",
        kVK_F7: "F7", kVK_F8: "F8", kVK_F9: "F9", kVK_F10: "F10", kVK_F11: "F11", kVK_F12: "F12",
        kVK_F13: "F13", kVK_F14: "F14", kVK_F15: "F15", kVK_F16: "F16", kVK_F17: "F17",
        kVK_F18: "F18", kVK_F19: "F19", kVK_F20: "F20"
    ]

    private static func label(for event: NSEvent) -> String {
        if let special = specialLabels[Int(event.keyCode)] { return special }
        let text = (event.charactersIgnoringModifiers ?? "").uppercased()
        return text.isEmpty ? "Key \(event.keyCode)" : text
    }

    // MARK: - Saving

    static func load(key: String = "quickCaptureShortcut",
                     fallback: Shortcut = .defaultShortcut,
                     from defaults: UserDefaults = .standard) -> Shortcut {
        guard let data = defaults.data(forKey: key),
              let saved = try? JSONDecoder().decode(Shortcut.self, from: data),
              saved.isAcceptable else {
            return fallback
        }
        return saved
    }

    func save(key: String = "quickCaptureShortcut", to defaults: UserDefaults = .standard) {
        if let data = try? JSONEncoder().encode(self) {
            defaults.set(data, forKey: key)
        }
    }
}
