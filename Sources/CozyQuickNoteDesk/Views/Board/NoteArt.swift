import SwiftUI

/// The artwork of one note design: near-white paper tinted with the note's colour,
/// plus an untinted layer of tape, bows and stickers on top.
struct NoteArt: View {
    let design: NoteDesign
    let tint: Color

    var body: some View {
        ZStack {
            if let paper = AppResources.image("note_\(design.rawValue)_paper") {
                Image(nsImage: paper)
                    .resizable()
                    .scaledToFit()
                    .colorMultiply(tint)
            } else {
                Rectangle().fill(tint).padding(10)      // fallback if the artwork is missing
            }
            if let deco = AppResources.image("note_\(design.rawValue)_deco") {
                Image(nsImage: deco)
                    .resizable()
                    .scaledToFit()
            }
        }
        .allowsHitTesting(false)
    }
}
