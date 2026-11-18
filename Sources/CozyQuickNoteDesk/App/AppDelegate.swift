import AppKit
import CoreServices

/// Decides whether "quit" really quits. Normally it only closes the room window, so the
/// shortcut keeps working; the menu bar's "Quit Completely" and a shutdown or logout are real quits.
enum AppLifecycle {
    /// Set by "Quit Completely" in the menu bar.
    static var allowQuit = false
    /// Set when the Mac is shutting down, restarting or logging out.
    static var systemIsEnding = false
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var escapeMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // No Dock icon unless the room window is open.
        NSApp.setActivationPolicy(.accessory)

        // A shutdown, restart or logout must never be blocked.
        NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.willPowerOffNotification, object: nil, queue: .main
        ) { _ in
            AppLifecycle.systemIsEnding = true
        }

        installEscapeHandler()

        HotKeyManager.shared.onTrigger = {
            LeafCaptureController.shared.toggle()
        }
        ShortcutSettings.shared.applyAtLaunch()

        // Started by you: show the room. Started by macOS at login: stay silent in the menu bar.
        if !Self.wasLaunchedAtLogin() {
            MainWindowController.shared.show()
            offerOpenAtLogin()
        }
    }

    // MARK: - Quitting

    /// ⌘Q and "Quit" in the Dock close the room instead of ending the app, so the shortcut survives.
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        if AppLifecycle.allowQuit || AppLifecycle.systemIsEnding { return .terminateNow }
        MainWindowController.shared.close()
        return .terminateCancel
    }

    /// Closing the room must not end the app.
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    /// Everything is saved again whenever the app really quits.
    func applicationWillTerminate(_ notification: Notification) {
        NoteManager.shared.saveNow()
    }

    /// Clicking the app's icon again (Launchpad, Finder) brings the room back.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !LeafCaptureController.shared.isShowing {
            MainWindowController.shared.show()
        }
        return true
    }

    // MARK: - Starting at login

    /// True when macOS opened the app because it is a login item.
    private static func wasLaunchedAtLogin() -> Bool {
        guard let event = NSAppleEventManager.shared().currentAppleEvent else { return false }
        return event.eventID == AEEventID(kAEOpenApplication)
            && event.paramDescriptor(forKeyword: AEKeyword(keyAEPropData))?.enumCodeValue
                == OSType(keyAELaunchedAsLogInItem)
    }

    /// One friendly question the first time the installed app runs.
    private func offerOpenAtLogin() {
        let key = "openAtLoginOffered"
        guard LoginItem.isAvailable, !LoginItem.isEnabled,
              !UserDefaults.standard.bool(forKey: key) else { return }
        UserDefaults.standard.set(true, forKey: key)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let alert = NSAlert()
            alert.messageText = "Open Cozy Quick-Note Desk when you log in?"
            alert.informativeText = "The shortcut (\(ShortcutSettings.shared.display)) only works while the app is running. "
                + "Opening it at login keeps it quietly in the menu bar, with no window and no Dock icon, "
                + "so the leaf is always one key press away. You can change this any time in Settings."
            alert.addButton(withTitle: "Open at Login")
            alert.addButton(withTitle: "Not Now")
            if alert.runModal() == .alertFirstButtonReturn {
                try? LoginItem.setEnabled(true)
            }
        }
    }

    // MARK: - Keys

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
}
