import SwiftUI

/// One sticky note on the cork board: draggable, editable in place, tilted a few degrees.
struct StickyNoteView: View {
    let note: Note
    /// The cork surface in window coordinates.
    let board: CGRect

    @EnvironmentObject private var manager: NoteManager
    @AppStorage("noteFontSize") private var fontSize = 15.0
    @ObservedObject private var navigation = AppNavigation.shared

    @State private var dragOffset: CGSize = .zero
    @State private var isHovering = false
    @State private var isTicked = false
    @State private var isFading = false

    private let controlsHeight: CGFloat = 30

    private var baseSide: CGFloat { min(max(board.width * 0.17, 120), 180) }
    private var side: CGFloat { baseSide * CGFloat(note.design.sizeScale) }

    private var pinColor: Color {
        let colors = [Color(red: 0.78, green: 0.22, blue: 0.20),
                      Color(red: 0.22, green: 0.42, blue: 0.70),
                      Color(red: 0.24, green: 0.55, blue: 0.34),
                      Color(red: 0.90, green: 0.70, blue: 0.20)]
        return colors[Int(note.id.uuid.0) % colors.count]
    }

    var body: some View {
        VStack(spacing: 2) {
            paper
            controls
        }
        .frame(width: side, height: side + controlsHeight)
        .onHover { isHovering = $0 }
        .rotationEffect(.degrees(note.tiltDegrees))
        .opacity(isFading ? 0 : 1)
        .scaleEffect(isFading ? 0.92 : 1)
        // Placed with .offset from the board's top-left corner instead of .position.
        // .position made every note's frame as big as the whole room, so the newest note
        // swallowed clicks meant for the notes underneath it (they could only be ticked
        // in the order they were added).
        .offset(x: board.minX + CGFloat(note.positionX) * board.width - side / 2 + dragOffset.width,
                y: board.minY + CGFloat(note.positionY) * board.height - (side + controlsHeight) / 2 + dragOffset.height)
    }

    // MARK: - Paper

    private var paper: some View {
        let tr = note.design.textRect
        return ZStack {
            NoteArt(design: note.design, tint: note.color.color)
                .frame(width: side, height: side)
                .shadow(color: .black.opacity(0.38), radius: 4, x: 2, y: 4)

            TextEditor(text: Binding(
                get: { note.text },
                set: { manager.updateText(id: note.id, text: $0) }
            ))
            .font(Theme.hand(CGFloat(fontSize)))
            .foregroundColor(Theme.ink)
            .scrollContentBackground(.hidden)
            .frame(width: tr.width * side, height: tr.height * side)
            .position(x: tr.midX * side, y: tr.midY * side)

            if navigation.highlightedNoteID == note.id {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Color(red: 1.0, green: 0.84, blue: 0.35), lineWidth: 5)
                    .shadow(color: Color(red: 1.0, green: 0.78, blue: 0.2), radius: 12)
                    .frame(width: side - 6, height: side - 6)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            if let pinY = note.design.pinY {
                PushPin(color: pinColor)
                    .position(x: side / 2, y: CGFloat(pinY) * side)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: side, height: side)
        // Dragging works from the paper margins; the text box handles its own clicks,
        // so dragging never fights with text selection.
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .onTapGesture { manager.bringToFront(id: note.id) }   // clicking a note lifts it above its neighbours
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 3, coordinateSpace: .global)
            .onChanged { value in
                if dragOffset == .zero { manager.bringToFront(id: note.id) }
                dragOffset = value.translation
            }
            .onEnded { value in
                let x = (CGFloat(note.positionX) * board.width + value.translation.width) / board.width
                let y = (CGFloat(note.positionY) * board.height + value.translation.height) / board.height
                manager.move(id: note.id,
                             toX: min(max(Double(x), 0.05), 0.95),
                             y: min(max(Double(y), 0.08), 0.84))
                dragOffset = .zero
            }
    }

    // MARK: - Controls

    private var controls: some View {
        HStack(spacing: 8) {
            Button(action: complete) {
                ZStack {
                    Circle().strokeBorder(Theme.ink.opacity(0.7), lineWidth: 1.5)
                    if isTicked {
                        Circle().fill(Color.green)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 20, height: 20)
                .frame(width: 30, height: 26)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Mark as done")

            Spacer(minLength: 0)

            Menu {
                ForEach(NoteColor.allCases) { option in
                    Button(option.label) { manager.updateColor(id: note.id, color: option) }
                }
            } label: {
                Image(systemName: "paintpalette")
                    .frame(width: 26, height: 26)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .fixedSize()
            .help("Change colour")

            Button { manager.delete(id: note.id) } label: {
                Image(systemName: "trash")
                    .frame(width: 28, height: 26)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Delete")
        }
        .foregroundColor(Theme.ink)
        .padding(.horizontal, 6)
        .frame(width: side * 0.78, height: controlsHeight - 2)
        .background(Capsule().fill(Theme.cream.opacity(0.92)))
        .overlay(Capsule().strokeBorder(Theme.walnut.opacity(0.35), lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 2)
        .opacity(isHovering || isTicked ? 1 : 0.65)
    }

    /// Green tick, a gentle fade, then the note moves into the Archive (never deleted).
    private func complete() {
        guard !isTicked else { return }
        withAnimation(.easeIn(duration: 0.2)) { isTicked = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.7)) { isFading = true }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.15) {
            manager.complete(id: note.id)
        }
    }
}
