import AppKit

/// How much bigger than its resting size a note must be so that its text fits without scrolling.
///
/// The whole note is scaled evenly (picture, stickers, writing area), so the artwork is never
/// stretched. The text keeps its size, so a bigger note simply has room for more lines.
enum NoteGrowth {
    private static var cache: [String: CGFloat] = [:]

    /// - Parameters:
    ///   - side: the note's resting size (the square the artwork is drawn in)
    ///   - maxScale: the largest allowed growth; beyond it the text scrolls
    /// - Returns: 1 when the text already fits, otherwise the smallest scale (in steps of 0.05) that fits.
    static func scale(text: String, design: NoteDesign, side: CGFloat, fontSize: CGFloat, maxScale: CGFloat) -> CGFloat {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Short notes never need to grow; skip the measuring.
        guard maxScale > 1, trimmed.count > 24 || trimmed.contains("\n") else { return 1 }

        let key = "\(design.rawValue)|\(Int(side))|\(Int(fontSize))|\(Int(maxScale * 100))|\(text)"
        if let known = cache[key] { return known }

        let font = measuringFont(size: fontSize)
        let area = design.textRect
        var result = maxScale
        var candidate: CGFloat = 1
        while candidate <= maxScale + 0.001 {
            let width = area.width * side * candidate - 14      // the text box keeps a little padding
            let height = area.height * side * candidate - 8
            if textHeight(text, font: font, width: width) * 1.06 <= height {
                result = candidate
                break
            }
            candidate += 0.05
        }

        if cache.count > 600 { cache.removeAll() }
        cache[key] = result
        return result
    }

    // MARK: - Measuring

    private static func measuringFont(size: CGFloat) -> NSFont {
        NSFont(name: "Noteworthy-Light", size: size)
            ?? NSFont(name: "Noteworthy", size: size)
            ?? NSFont.systemFont(ofSize: size)
    }

    private static func textHeight(_ text: String, font: NSFont, width: CGFloat) -> CGFloat {
        // A trailing new line still takes a line of space.
        let measured = text.hasSuffix("\n") ? text + " " : text
        let attributed = NSAttributedString(string: measured, attributes: [.font: font])
        let box = attributed.boundingRect(
            with: NSSize(width: max(20, width), height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        return ceil(box.height)
    }
}
