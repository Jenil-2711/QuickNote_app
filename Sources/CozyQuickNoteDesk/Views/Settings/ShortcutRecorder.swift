import SwiftUI
import Carbon.HIToolbox

/// Click it, press the keys you want, done. Esc cancels, Delete resets to the default.
struct ShortcutRecorder: View {
    @ObservedObject var settings: ShortcutSettings

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack(spacing: 10) {
            Button {
                if isRecording { stopRecording(cancelled: true) } else { startRecording() }
            } label: {
                Text(isRecording ? "Press the new shortcut…" : settings.display)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .frame(minWidth: 170)
            }
            .buttonStyle(CozyButtonStyle(kind: isRecording ? .primary : .plain))
            .help("Click, then press the keys you want to use")

            Button("Reset") { settings.resetToDefault() }
                .buttonStyle(CozyButtonStyle(kind: .plain))
                .disabled(settings.shortcut == Shortcut.defaultShortcut)
                .opacity(settings.shortcut == Shortcut.defaultShortcut ? 0.5 : 1)
        }
        .onDisappear {
            if isRecording { stopRecording(cancelled: true) }
        }
    }

    // MARK: - Recording

    private func startRecording() {
        isRecording = true
        settings.message = nil
        settings.suspendHotKey()       // so pressing the current shortcut records it instead of firing it

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handle(event)
            return nil                 // swallow every key while recording
        }
    }

    private func handle(_ event: NSEvent) {
        let noModifiers = event.modifierFlags
            .intersection(.deviceIndependentFlagsMask)
            .intersection([.command, .option, .control, .shift])
            .isEmpty
        let code = Int(event.keyCode)

        if code == kVK_Escape && noModifiers {
            stopRecording(cancelled: true)
        } else if (code == kVK_Delete || code == kVK_ForwardDelete) && noModifiers {
            stopRecording(cancelled: false)
            settings.resetToDefault()
        } else {
            stopRecording(cancelled: false)
            settings.change(to: Shortcut.from(event: event))
        }
    }

    private func stopRecording(cancelled: Bool) {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        isRecording = false
        if cancelled { settings.resumeHotKey() }
    }
}
