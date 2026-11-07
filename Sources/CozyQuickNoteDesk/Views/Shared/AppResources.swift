import AppKit

enum AppResources {
    /// Finds the resource bundle inside a packaged .app, otherwise falls back to SwiftPM's own.
    static let bundle: Bundle = {
        let name = "CozyQuickNoteDesk_CozyQuickNoteDesk.bundle"
        if let url = Bundle.main.resourceURL?.appendingPathComponent(name),
           let packaged = Bundle(url: url) {
            return packaged
        }
        return Bundle.module
    }()

    /// Loads `name.png` or `name.jpg` from the Resources folder, or nil if neither exists.
    static func image(_ name: String) -> NSImage? {
        for ext in ["png", "jpg"] {
            if let url = bundle.url(forResource: name, withExtension: ext),
               let image = NSImage(contentsOf: url) {
                return image
            }
        }
        return nil
    }
}
