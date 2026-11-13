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

    private static let cache = NSCache<NSString, NSImage>()

    /// Loads `name.png` or `name.jpg` from the Resources folder (cached), or nil if neither exists.
    static func image(_ name: String) -> NSImage? {
        if let cached = cache.object(forKey: name as NSString) { return cached }
        for ext in ["png", "jpg"] {
            if let url = bundle.url(forResource: name, withExtension: ext),
               let image = NSImage(contentsOf: url) {
                cache.setObject(image, forKey: name as NSString)
                return image
            }
        }
        return nil
    }
}
