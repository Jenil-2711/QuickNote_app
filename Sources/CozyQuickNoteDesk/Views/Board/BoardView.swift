import SwiftUI

/// The main screen: the study room, with sticky notes pinned to the cork board.
struct BoardView: View {
    @EnvironmentObject private var manager: NoteManager
    @AppStorage("showDecorations") private var showLights = true

    var body: some View {
        GeometryReader { geo in
            let room = RoomGeometry(size: geo.size)
            ZStack {
                RoomBackground(showLights: showLights)

                // Clicking empty wall or board drops the blinking cursor.
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { NSApp.keyWindow?.makeFirstResponder(nil) }

                // Notes are laid out from the top-left corner and moved with .offset,
                // so each note only occupies (and only catches clicks on) its own area.
                ZStack(alignment: .topLeading) {
                    ForEach(manager.activeNotes) { note in
                        StickyNoteView(note: note, board: room.boardRect)
                            .zIndex(Double(note.displayOrder))
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)

                if manager.activeNotes.isEmpty {
                    EmptyBoardTag()
                        .position(x: room.boardRect.midX, y: room.boardRect.midY)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()
            .overlay(alignment: .top) { warningTag }
        }
    }

    @ViewBuilder
    private var warningTag: some View {
        if let message = manager.warning {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(message).font(Theme.serif(12, weight: .regular))
                Spacer(minLength: 8)
                Button("Dismiss") { manager.warning = nil }
                    .buttonStyle(CozyButtonStyle(kind: .plain))
            }
            .foregroundColor(Theme.cream)
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.terracotta))
            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.walnut.opacity(0.5), lineWidth: 1))
            .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 4)
            .padding(14)
        }
    }
}

/// A little kraft-paper label shown on an empty board.
struct EmptyBoardTag: View {
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 26))
                .foregroundColor(Theme.sage)
            Text("Your board is clear")
                .font(Theme.serif(20))
                .foregroundColor(Theme.ink)
            Text("Press \(AppConstants.hotKeyDisplay) from anywhere to pin a thought.")
                .font(Theme.hand(15))
                .foregroundColor(Theme.ink.opacity(0.8))
        }
        .padding(.horizontal, 26)
        .padding(.vertical, 20)
        .background(PaperSurface(tint: Theme.beige).clipShape(RoundedRectangle(cornerRadius: 6)))
        .overlay(alignment: .top) {
            PushPin(color: Color(red: 0.78, green: 0.22, blue: 0.20)).offset(y: -6)
        }
        .rotationEffect(.degrees(-1.5))
        .shadow(color: .black.opacity(0.35), radius: 5, x: 2, y: 4)
        .allowsHitTesting(false)
    }
}
