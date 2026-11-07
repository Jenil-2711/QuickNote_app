import SwiftUI

@main
struct CozyQuickNoteDeskApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var manager = NoteManager.shared

    var body: some Scene {
        Window(AppConstants.appName, id: "desk") {
            RootView()
                .environmentObject(manager)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1200, height: 780)

        MenuBarExtra(AppConstants.appName, systemImage: "leaf.fill") {
            MenuBarContent()
                .environmentObject(manager)
        }

        Settings {
            SettingsView()
        }
    }
}

struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Drop a Leaf of Thought  (\(AppConstants.hotKeyDisplay))") {
            LeafCaptureController.shared.show()
        }
        Button("Open the Study Room") {
            NSApp.activate(ignoringOtherApps: true)
            openWindow(id: "desk")
        }
        Divider()
        Button("Quit \(AppConstants.appName)") {
            NSApp.terminate(nil)
        }
    }
}
