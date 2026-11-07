import SwiftUI

/// Only the essentials, dressed like the rest of the room: a walnut header over a paper sheet.
struct SettingsView: View {
    @AppStorage("showDecorations") private var showLights = true
    @AppStorage("noteFontSize") private var noteFontSize = 15.0

    var body: some View {
        VStack(spacing: 0) {
            Text("Settings")
                .font(Theme.serif(18))
                .foregroundColor(Theme.cream)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(WoodSurface())

            VStack(alignment: .leading, spacing: 22) {
                section("Quick capture") {
                    HStack(spacing: 12) {
                        Text("Shortcut").font(Theme.serif(14, weight: .regular))
                        Text(AppConstants.hotKeyDisplay)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(RoundedRectangle(cornerRadius: 6).fill(Theme.beige))
                            .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(Theme.walnut.opacity(0.4)))
                    }
                    Text("Built into the app. To change it, edit AppConstants.swift and rebuild.")
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
        .frame(width: 460, height: 340)
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
