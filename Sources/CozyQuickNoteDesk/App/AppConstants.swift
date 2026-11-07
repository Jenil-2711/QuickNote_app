import Carbon.HIToolbox

/// App-wide constants. The quick-capture shortcut is hard-coded on purpose:
/// change `hotKeyCode` / `hotKeyModifiers` / `hotKeyDisplay` and rebuild to use another one.
enum AppConstants {
    static let appName = "Cozy Quick-Note Desk"

    /// Control + Option + N
    static let hotKeyCode = UInt32(kVK_ANSI_N)
    static let hotKeyModifiers = UInt32(controlKey | optionKey)
    static let hotKeyDisplay = "⌃⌥N"
}
