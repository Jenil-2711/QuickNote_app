import AppKit
import Carbon.HIToolbox

/// Registers system-wide shortcuts using Carbon's RegisterEventHotKey.
/// This needs no extra helper app and no special permissions. Each shortcut has its own number,
/// so one app can have several (quick capture is 1, search is 2).
@MainActor
final class HotKeyManager {
    static let shared = HotKeyManager()

    private var handlers: [UInt32: @MainActor () -> Void] = [:]
    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var handlerRef: EventHandlerRef?

    /// What to do when the shortcut with this number is pressed.
    func setHandler(_ id: UInt32, _ handler: @escaping @MainActor () -> Void) {
        handlers[id] = handler
    }

    /// Makes `shortcut` the active global shortcut for `id`, replacing its previous one.
    /// Returns false if macOS refuses it (for example another app already owns it).
    @discardableResult
    func register(_ shortcut: Shortcut, id: UInt32) -> Bool {
        installHandlerIfNeeded()
        unregister(id: id)

        var ref: EventHotKeyRef?
        let hotKeyID = EventHotKeyID(signature: OSType(0x434E5444), id: id) // 'CNTD'
        let status = RegisterEventHotKey(shortcut.keyCode, shortcut.modifiers, hotKeyID,
                                         GetApplicationEventTarget(), 0, &ref)
        guard status == noErr, let ref else { return false }
        hotKeyRefs[id] = ref
        return true
    }

    func unregister(id: UInt32) {
        if let ref = hotKeyRefs[id] { UnregisterEventHotKey(ref) }
        hotKeyRefs[id] = nil
    }

    fileprivate func fire(_ id: UInt32) {
        handlers[id]?()
    }

    private func installHandlerIfNeeded() {
        guard handlerRef == nil else { return }
        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, event, userData in
                guard let userData, let event else { return noErr }
                var hotKeyID = EventHotKeyID()
                let status = GetEventParameter(
                    event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                    nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID
                )
                guard status == noErr else { return noErr }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                let id = hotKeyID.id
                Task { @MainActor in manager.fire(id) }
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            &handlerRef
        )
    }
}
