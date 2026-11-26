import AppKit
import SwiftUI

final class SearchPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// What you typed and which result is highlighted.
@MainActor
final class SearchModel: ObservableObject {
    @Published var query = "" { didSet { selection = 0 } }
    @Published var selection = 0

    var results: [Note] { NoteSearch.results(for: query, in: NoteManager.shared.notes) }

    var selectedNote: Note? {
        let found = results
        return found.indices.contains(selection) ? found[selection] : nil
    }

    func moveSelection(_ delta: Int) {
        let count = results.count
        guard count > 0 else { return }
        selection = (selection + delta + count) % count
    }

    func reset() {
        query = ""
        selection = 0
    }
}

/// Shows and hides the search window when its global shortcut is pressed.
@MainActor
final class SearchController {
    static let shared = SearchController()

    let model = SearchModel()
    private var panel: SearchPanel?
    private let panelSize = NSSize(width: 620, height: 520)

    var isShowing: Bool { panel?.isVisible == true }

    func toggle() {
        if isShowing { hide() } else { show() }
    }

    func show() {
        model.reset()
        let panel = self.panel ?? makePanel()
        self.panel = panel

        let view = SearchView(model: model) { [weak self] note in self?.open(note) }
        let host = NSHostingView(rootView: view)
        host.frame = NSRect(origin: .zero, size: panelSize)
        panel.contentView = host

        panel.setFrameOrigin(origin(on: screenUnderMouse()))
        panel.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel?.orderOut(nil)
        panel?.contentView = nil          // release the views while it is out of sight
    }

    /// Closes the search and takes you to the note.
    func open(_ note: Note) {
        hide()
        AppNavigation.shared.reveal(note)
        MainWindowController.shared.show()
    }

    // MARK: - Private

    private func makePanel() -> SearchPanel {
        let panel = SearchPanel(
            contentRect: NSRect(origin: .zero, size: panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        return panel
    }

    private func screenUnderMouse() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { NSMouseInRect(mouse, $0.frame, false) } ?? NSScreen.main
    }

    /// Upper third of the screen, like a launcher.
    private func origin(on screen: NSScreen?) -> NSPoint {
        guard let frame = screen?.visibleFrame else { return .zero }
        return NSPoint(x: frame.midX - panelSize.width / 2,
                       y: frame.maxY - panelSize.height - frame.height * 0.14)
    }
}
