import SwiftUI

/// Completed notes, filed on index cards inside a wooden-framed paper panel,
/// with the study room softly blurred behind it.
struct ArchiveView: View {
    @EnvironmentObject private var manager: NoteManager
    @State private var noteToDelete: Note?

    var body: some View {
        ZStack {
            RoomBackground(showLights: false, dim: 0.30, blur: 8)

            panel
                .frame(maxWidth: 800, maxHeight: .infinity)
                .padding(.horizontal, 32)
                .padding(.vertical, 24)

            if let note = noteToDelete {
                confirmation(for: note)
            }
        }
    }

    // MARK: - Panel

    private var panel: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("The Archive")
                    .font(Theme.serif(26))
                    .foregroundColor(Theme.ink)
                Text("Finished notes rest here. Restore them or let them go.")
                    .font(Theme.hand(14))
                    .foregroundColor(Theme.ink.opacity(0.7))
            }
            .padding(.top, 20)
            .padding(.bottom, 14)

            Rectangle().fill(Theme.walnut.opacity(0.25)).frame(height: 1).padding(.horizontal, 24)

            if manager.archivedNotes.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "leaf.fill").font(.system(size: 30)).foregroundColor(Theme.sage)
                    Text("Nothing filed yet").font(Theme.serif(18)).foregroundColor(Theme.ink)
                    Text("Tick the circle on a note and it will rest here.")
                        .font(Theme.hand(15)).foregroundColor(Theme.ink.opacity(0.75))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(manager.archivedNotes) { note in
                            card(for: note)
                        }
                    }
                    .padding(20)
                }
            }
        }
        .background(PaperSurface())
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(10)
        .background(WoodSurface().clipShape(RoundedRectangle(cornerRadius: 14)))
        .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(Color.black.opacity(0.5), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 10)
    }

    private func card(for note: Note) -> some View {
        HStack(alignment: .top, spacing: 14) {
            RoundedRectangle(cornerRadius: 4)
                .fill(note.color.color)
                .frame(width: 12)
                .overlay(RoundedRectangle(cornerRadius: 4).strokeBorder(Theme.walnut.opacity(0.35), lineWidth: 1))

            VStack(alignment: .leading, spacing: 5) {
                Text(note.text.isEmpty ? "(empty note)" : note.text)
                    .font(Theme.hand(17))
                    .foregroundColor(Theme.ink)
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(dates(for: note))
                    .font(Theme.serif(11, weight: .regular))
                    .foregroundColor(Theme.ink.opacity(0.6))
            }

            VStack(spacing: 8) {
                Button("Restore") { manager.restore(id: note.id) }
                    .buttonStyle(CozyButtonStyle(kind: .primary))
                Button("Delete") { noteToDelete = note }
                    .buttonStyle(CozyButtonStyle(kind: .danger))
            }
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 8).fill(note.color.color.opacity(0.35)))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Theme.walnut.opacity(0.3), lineWidth: 1))
        .shadow(color: .black.opacity(0.18), radius: 3, x: 0, y: 2)
    }

    private func dates(for note: Note) -> String {
        var text = "Created \(note.createdAt.formatted(date: .abbreviated, time: .shortened))"
        if let done = note.completedAt {
            text += "  ·  Completed \(done.formatted(date: .abbreviated, time: .shortened))"
        }
        return text
    }

    // MARK: - Delete confirmation (a paper card, not a system alert)

    private func confirmation(for note: Note) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { noteToDelete = nil }

            VStack(spacing: 14) {
                Text("Delete permanently?")
                    .font(Theme.serif(20))
                    .foregroundColor(Theme.ink)
                Text("This note will be gone for good.")
                    .font(Theme.hand(16))
                    .foregroundColor(Theme.ink.opacity(0.8))
                HStack(spacing: 12) {
                    Button("Keep it") { noteToDelete = nil }
                        .buttonStyle(CozyButtonStyle(kind: .plain))
                    Button("Delete") {
                        manager.delete(id: note.id)
                        noteToDelete = nil
                    }
                    .buttonStyle(CozyButtonStyle(kind: .danger))
                }
            }
            .padding(26)
            .frame(width: 340)
            .background(PaperSurface().clipShape(RoundedRectangle(cornerRadius: 8)))
            .padding(8)
            .background(WoodSurface().clipShape(RoundedRectangle(cornerRadius: 12)))
            .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 10)
        }
    }
}
