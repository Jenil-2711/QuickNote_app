import AppKit
import SwiftUI

/// Owns the study-room window. The window is created only when you ask for it and fully destroyed
/// when you close it, so while you are not looking at your notes the app holds almost no memory,
/// has no Dock icon, and does no drawing at all.
@MainActor
final class MainWindowController: NSObject, NSWindowDelegate {
    static let shared = MainWindowController()

    private var window: NSWindow?

    /// Opens the room (or brings it to the front) and gives the app its Dock icon while it is open.
    func show() {
        NSApp.setActivationPolicy(.regular)
        if window == nil { window = makeWindow() }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    /// Closes the room; the app carries on quietly in the menu bar.
    func close() {
        window?.close()
    }

    // MARK: - NSWindowDelegate

    func windowWillClose(_ notification: Notification) {
        window?.delegate = nil
        window?.contentViewController = nil      // frees the whole SwiftUI view tree
        window = nil
        AppResources.clearCache()                // frees the decoded room picture and textures
        NSApp.setActivationPolicy(.accessory)    // Dock icon disappears, shortcut keeps working
    }

    // MARK: - Building the window

    private func makeWindow() -> NSWindow {
        let controller = NSHostingController(rootView: RootView().environmentObject(NoteManager.shared))
        controller.sizingOptions = []

        let window = NSWindow(contentViewController: controller)
        window.title = AppConstants.appName
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isReleasedWhenClosed = false
        window.contentMinSize = NSSize(width: 900, height: 620)
        window.setContentSize(NSSize(width: 1200, height: 780))
        window.center()
        window.setFrameAutosaveName("StudyRoomWindow")     // remembers where you left it
        window.delegate = self
        return window
    }
}
