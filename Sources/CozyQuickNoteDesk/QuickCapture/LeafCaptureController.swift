import AppKit
import SwiftUI

/// A borderless, fully transparent panel: only the leaf is visible on screen.
final class LeafPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// Shows and hides the floating leaf when the global shortcut is pressed.
@MainActor
final class LeafCaptureController: NSObject {
    static let shared = LeafCaptureController()

    private var panel: LeafPanel?
    private let panelSize = NSSize(width: 620, height: 720)

    var isShowing: Bool { panel?.isVisible == true }

    func toggle() {
        if isShowing { hide() } else { show() }
    }

    func show() {
        let panel = self.panel ?? makePanel()
        self.panel = panel

        // Fresh view every time so the text box gets focus and the saved draft is reloaded.
        let view = LeafCaptureView(
            onSave: { [weak self] text, color in self?.save(text: text, color: color) },
            onClose: { [weak self] in self?.hide() }
        )
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: panelSize)
        panel.contentView = host

        panel.setFrameOrigin(origin(on: screenUnderMouse()))
        panel.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel?.orderOut(nil)
        panel?.contentView = nil          // release the leaf's views while it is out of sight
    }

    // MARK: - Private

    private func save(text: String, color: NoteColor) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            NoteManager.shared.addNote(text: trimmed, color: color)
            LeafDraft.clearText()
        }
        hide()
    }

    private func makePanel() -> LeafPanel {
        let panel = LeafPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.isMovableByWindowBackground = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        return panel
    }

    private func screenUnderMouse() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
    }

    private func origin(on screen: NSScreen?) -> NSPoint {
        guard let frame = screen?.visibleFrame else { return .zero }
        return NSPoint(
            x: frame.midX - panelSize.width / 2,
            y: frame.midY - panelSize.height / 2 + 30
        )
    }
}
