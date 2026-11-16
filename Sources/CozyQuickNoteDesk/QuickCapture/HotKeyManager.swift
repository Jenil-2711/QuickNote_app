import AppKit
import Carbon.HIToolbox

/// Registers one system-wide shortcut using Carbon's RegisterEventHotKey.
/// This needs no extra helper app and no special permissions.
@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()

    var onTrigger: (@MainActor () -> Void)?

    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    /// Makes `shortcut` the active global shortcut, replacing the previous one.
    /// Returns false if macOS refuses it (for example another app already owns it).
    @discardableResult
    func register(_ shortcut: Shortcut) -> Bool {
        installHandlerIfNeeded()
        unregister()

        let hotKeyID = EventHotKeyID(signature: OSType(0x434E5444), id: 1) // 'CNTD'
        let status = RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers, hotKeyID,
                                         GetApplicationEventTarget(), 0, &hotKeyRef)
        if status != noErr { hotKeyRef = nil }
        return status == noErr
    }

    func unregister() {
        if let hotKeyRef { UnregisterEventHotKey(hotKeyRef) }
        hotKeyRef = nil
    }

    private func installHandlerIfNeeded() {
        guard handlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, _, userData in
                guard let userData else { return noErr }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                Task { @MainActor in manager.onTrigger?() }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerRef
        )
    }
}
