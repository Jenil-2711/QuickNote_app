import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var escapeMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Needed when launched via `swift run` (no .app bundle): gives us a Dock icon and focus.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        installEscapeHandler()

        HotKeyManager.shared.onTrigger = {
            LeafCaptureController.shared.toggle()
        }
        ShortcutSettings.shared.applyAtLaunch()
    }

    /// Esc: the first press leaves the text box (stops the blinking cursor);
    /// on the leaf, a second press closes it.
    private func installEscapeHandler() {
        escapeMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 53, let window = event.window ?? NSApp.keyWindow else { return event }
            if window.firstResponder is NSTextView {
                window.makeFirstResponder(nil)
                return nil
            }
            if window is LeafPanel {
                LeafCaptureController.shared.hide()
                return nil
            }
            return event
        }
    }

    /// Closing the main window keeps the app alive in the menu bar so the shortcut keeps working.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// Everything is saved again when the app quits.
    func applicationWillTerminate(_ notification: Notification) {
        NoteManager.shared.saveNow()
    }
}
