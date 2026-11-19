import SwiftUI

/// The app has no window of its own at start-up: it lives in the menu bar. The study-room
/// window is created on demand by MainWindowController.
@main
struct CozyQuickNoteDeskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        SingleInstance.claimOrExit()      // a second copy hands over to the first and quits
    }

    var body: some Scene {
        MenuBarExtra(AppConstants.appName, systemImage: "leaf.fill") {
            MenuBarContent()
        }

        Settings {
            SettingsView()
        }
    }
}

struct MenuBarContent: View {
    @ObservedObject private var shortcuts = ShortcutSettings.shared

    var body: some View {
        Button("Drop a Leaf of Thought  (\(shortcuts.display))") {
            LeafCaptureController.shared.show()
        }
        Button("Open the Study Room") {
            MainWindowController.shared.show()
        }
        Button("Settings…") {
            NSApp.activate(ignoringOtherApps: true)
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        }
        Divider()
        Button("Quit Completely (turns the shortcut off)") {
            AppLifecycle.allowQuit = true
            NSApp.terminate(nil)
        }
    }
}
