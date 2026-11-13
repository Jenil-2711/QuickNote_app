import SwiftUI

/// Completed notes, filed on index cards inside a wooden-framed paper panel,
/// with the study room softly blurred behind it.
struct ArchiveView: View {
    /// What the confirmation is asking about.
    private enum PendingDelete {
        case note(Note)
        case everything(count: Int)
    }

    @EnvironmentObject private var manager: NoteManager
    @State private var pending: PendingDelete?

    var body: some View {
        ZStack {
            RoomBackground(showLights: false, dim: 0.30, blur: 8)

            panel
                .frame(maxWidth: 800, maxHeight: .infinity)
                .padding(.horizontal, 32)
                .padding(.vertical, 24)
        }
        // One standard macOS confirmation for both "delete this note" and "empty the archive".
        .alert(alertTitle,
               isPresented: Binding(get: { pending != nil },
                                    set: { if !$0 { pending = nil } }),
               presenting: pending) { action in
            Button("Keep it", role: .cancel) {}
            Button(confirmLabel(for: action), role: .destructive) {
                switch action {
                case .note(let note):
                    manager.delete(id: note.id)
                case .everything:
                    manager.deleteAllArchived()
                }
            }
        } message: { action in
            Text(message(for: action))
        }
    }

    // MARK: - Panel

    private var panel: some View {
        VStack(spacing: 0) {
            header

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

            if !manager.archivedNotes.isEmpty {
                Rectangle().fill(Theme.walnut.opacity(0.25)).frame(height: 1).padding(.horizontal, 24)
                footer
            }
        }
        .background(PaperSurface())
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(10)
        .background(WoodSurface().clipShape(RoundedRectangle(cornerRadius: 14)))
        .shadow(color: .black.opacity(0.5), radius: 18, x: 0, y: 10)
    }

    private var header: some View {
        VStack(spacing: 2) {
            Text("The Archive")
                .font(Theme.serif(26))
                .foregroundColor(Theme.ink)
            Text("Finished notes rest here. Restore them or let them go.")
                .font(Theme.hand(14))
                .foregroundColor(Theme.ink.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
        .padding(.bottom, 14)
    }

    /// Bottom bar with the count and the "Empty Archive" button.
    private var footer: some View {
        let count = manager.archivedNotes.count
        return HStack(spacing: 12) {
            Text(count == 1 ? "1 finished note" : "\(count) finished notes")
                .font(Theme.hand(15))
                .foregroundColor(Theme.ink.opacity(0.75))
            Spacer(minLength: 12)
            Button("Empty Archive") {
                pending = .everything(count: count)
            }
            .buttonStyle(CozyButtonStyle(kind: .danger))
            .help("Permanently delete every finished note")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
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
                Button("Delete") { pending = .note(note) }
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

    // MARK: - Confirmation wording

    private var alertTitle: String {
        switch pending {
        case .some(.everything): return "Empty the archive?"
        default:                 return "Delete permanently?"
        }
    }

    private func confirmLabel(for action: PendingDelete) -> String {
        switch action {
        case .note:       return "Delete"
        case .everything: return "Empty Archive"
        }
    }

    private func message(for action: PendingDelete) -> String {
        switch action {
        case .note:
            return "This note will be gone for good."
        case .everything(let count):
            return count == 1 ? "The 1 finished note will be gone for good."
                              : "All \(count) finished notes will be gone for good."
        }
    }
}
