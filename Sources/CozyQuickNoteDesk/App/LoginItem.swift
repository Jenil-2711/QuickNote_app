import Foundation
import ServiceManagement

/// "Open at login": lets macOS start the app when you log in, so the shortcut is always ready.
/// This only works for the installed app (a .app bundle), not for `swift run`.
enum LoginItem {
    static var isAvailable: Bool { Bundle.main.bundlePath.hasSuffix(".app") }

    static var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    /// True when the user must also switch it on in System Settings → General → Login Items.
    static var needsApproval: Bool { SMAppService.mainApp.status == .requiresApproval }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
    }
}
