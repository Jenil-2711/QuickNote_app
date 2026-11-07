import SwiftUI

/// The popup: a transparent maple leaf you write your thought on.
struct LeafCaptureView: View {
    let onSave: (String, NoteColor) -> Void
    let onClose: () -> Void

    @State private var text: String = LeafDraft.text
    @State private var color: NoteColor = LeafDraft.color
    @FocusState private var focused: Bool

    // The writing area, as fractions of the leaf image (matches the pale glow in leaf.png).
    private let writing = CGRect(x: 0.27, y: 0.44, width: 0.46, height: 0.27)

    var body: some View {
        VStack(spacing: 14) {
            leaf
            controls
        }
        .padding(30)
        .onAppear { DispatchQueue.main.async { focused = true } }
    }

    // MARK: - Leaf

    private var leaf: some View {
        Group {
            if let image = AppResources.image("leaf") {
                Image(nsImage: image).resizable().scaledToFit()
            } else {
                Image(systemName: "leaf.fill").resizable().scaledToFit().foregroundColor(.orange)
            }
        }
        .frame(width: 560)
        .shadow(color: .black.opacity(0.30), radius: 16, x: 0, y: 10)
        .overlay(
            GeometryReader { geo in
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("A thought, an idea…")
                            .font(Theme.hand(18))
                            .foregroundColor(Theme.ink.opacity(0.45))
                            .padding(.horizontal, 5)
                            .padding(.top, 8)
                            .allowsHitTesting(false)
                    }
                    TextEditor(text: textBinding)
                        .font(Theme.hand(18))
                        .foregroundColor(Theme.ink)
                        .scrollContentBackground(.hidden)
                        .focused($focused)
                }
                .frame(width: geo.size.width * writing.width,
                       height: geo.size.height * writing.height)
                .offset(x: geo.size.width * writing.minX,
                        y: geo.size.height * writing.minY)
            }
        )
    }

    private var textBinding: Binding<String> {
        Binding(
            get: { text },
            set: { newValue in
                text = newValue
                LeafDraft.text = newValue      // autosave the draft while typing
            }
        )
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 12) {
            ForEach(NoteColor.allCases) { option in
                Circle()
                    .fill(option.color)
                    .frame(width: 20, height: 20)
                    .overlay(Circle().strokeBorder(Theme.walnut.opacity(color == option ? 0.9 : 0.25),
                                                   lineWidth: color == option ? 2 : 1))
                    .onTapGesture {
                        color = option
                        LeafDraft.color = option
                    }
                    .help(option.label)
            }
            Spacer(minLength: 12)
            Button("Close") { onClose() }                              // Esc is handled in AppDelegate
                .buttonStyle(CozyButtonStyle(kind: .plain))
            Button("Pin it") { onSave(text, color) }
                .keyboardShortcut(.return, modifiers: .command)        // ⌘↩
                .buttonStyle(CozyButtonStyle(kind: .primary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(PaperSurface().clipShape(Capsule()))
        .overlay(Capsule().strokeBorder(Theme.walnut.opacity(0.55), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 4)
        .frame(width: 460)
    }
}
