import SwiftUI

/// Only the essentials, dressed like the rest of the room: a walnut header over a paper sheet.
struct SettingsView: View {
    @AppStorage("showDecorations") private var showLights = true
    @AppStorage("noteFontSize") private var noteFontSize = 15.0
    @ObservedObject private var captureShortcut = ShortcutSettings.capture
    @ObservedObject private var searchShortcut = ShortcutSettings.search
    @State private var openAtLogin = LoginItem.isEnabled
    @State private var startupMessage: String?

    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(Theme.serif(18))
                .foregroundColor(Theme.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(WoodSurface())

            VStack(alignment: .leading, spacing: 22) {
                section("Shortcuts") {
                    shortcutRow(captureShortcut)
                    shortcutRow(searchShortcut)
                    Text("Click a shortcut, then press the keys you want. Esc cancels, Delete resets it.")
                        .font(Theme.hand(13))
                        .foregroundColor(Theme.ink.opacity(0.7))
                }

                section("Startup") {
                    Toggle("Open at login", isOn: openAtLoginBinding)
                        .toggleStyle(.switch)
                        .tint(Theme.sage)
                        .disabled(!LoginItem.isAvailable)
                    if let message = startupMessage {
                        Text(message)
                            .font(Theme.hand(13))
                            .foregroundColor(Theme.terracotta)
                    }
                    Text(LoginItem.isAvailable
                         ? "Keeps the app quietly in the menu bar after you log in, so the shortcut always works."
                         : "Available once the app is installed in your Applications folder.")
                        .font(Theme.hand(13))
                        .foregroundColor(Theme.ink.opacity(0.7))
                }

                section("Appearance") {
                    Toggle("Twinkling fairy lights", isOn: $showLights)
                        .toggleStyle(.switch)
                        .tint(Theme.sage)
                    Stepper("Note text size: \(Int(noteFontSize))", value: $noteFontSize, in: 12...22)
                }

                Spacer(minLength: 0)
            }
            .font(Theme.serif(14, weight: .regular))
            .foregroundColor(Theme.ink)
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(PaperSurface())
        }
        .frame(width: 500, height: 560)
    }

    private func shortcutRow(_ settings: ShortcutSettings) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Text(settings.action.title)
                    .font(Theme.serif(14, weight: .regular))
                    .frame(width: 110, alignment: .leading)
                ShortcutRecorder(settings: settings)
            }
            if let message = settings.message {
                Text(message)
                    .font(Theme.hand(13))
                    .foregroundColor(Theme.terracotta)
            }
        }
    }

    private var openAtLoginBinding: Binding<Bool> {
        Binding(
            get: { openAtLogin },
            set: { wanted in
                do {
                    try LoginItem.setEnabled(wanted)
                    startupMessage = LoginItem.needsApproval
                        ? "Also allow it in System Settings → General → Login Items."
                        : nil
                } catch {
                    startupMessage = "Couldn't change this: \(error.localizedDescription)"
                }
                openAtLogin = LoginItem.isEnabled
            }
        )
    }

    private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(Theme.serif(16))
                .foregroundColor(Theme.walnut)
            Rectangle().fill(Theme.walnut.opacity(0.25)).frame(height: 1)
            content()
        }
    }
}
