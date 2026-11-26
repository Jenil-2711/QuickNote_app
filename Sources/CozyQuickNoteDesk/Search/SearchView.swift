import SwiftUI

/// The search window: a field at the top and the matching notes below it.
struct SearchView: View {
    @ObservedObject var model: SearchModel
    let onOpen: (Note) -> Void

    @FocusState private var focused: Bool

    var body: some View {
        let results = model.results

        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Theme.walnut.opacity(0.7))
                TextField("Search your notes…", text: $model.query)
                    .textFieldStyle(.plain)
                    .font(Theme.hand(20))
                    .foregroundColor(Theme.ink)
                    .focused($focused)
                    .onSubmit {
                        if let note = model.selectedNote { onOpen(note) }
                    }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            Rectangle().fill(Theme.walnut.opacity(0.25)).frame(height: 1)

            if results.isEmpty {
                Text(model.query.isEmpty ? "No notes yet." : "No notes match.")
                    .font(Theme.hand(16))
                    .foregroundColor(Theme.ink.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 26)
            } else {
                VStack(spacing: 4) {
                    ForEach(Array(results.enumerated()), id: \.element.id) { index, note in
                        row(note, selected: index == model.selection)
                            .onTapGesture { onOpen(note) }
                    }
                }
                .padding(10)
            }

            Rectangle().fill(Theme.walnut.opacity(0.25)).frame(height: 1)
            Text("↑ ↓ choose  ·  ↩ open  ·  esc close")
                .font(Theme.serif(11, weight: .regular))
                .foregroundColor(Theme.ink.opacity(0.55))
                .padding(.vertical, 8)
        }
        .frame(width: 560)
        .background(PaperSurface().clipShape(RoundedRectangle(cornerRadius: 8)))
        .padding(8)
        .background(WoodSurface().clipShape(RoundedRectangle(cornerRadius: 14)))
        .shadow(color: .black.opacity(0.45), radius: 16, x: 0, y: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear { DispatchQueue.main.async { focused = true } }
    }

    private func row(_ note: Note, selected: Bool) -> some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 3)
                .fill(note.color.color)
                .frame(width: 10, height: 34)
                .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(Theme.walnut.opacity(0.35), lineWidth: 1))

            Text(snippet(of: note.text))
                .font(Theme.hand(16))
                .foregroundColor(Theme.ink)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            if note.isCompleted {
                Text("Archive")
                    .font(Theme.serif(11))
                    .foregroundColor(Theme.cream)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(Theme.walnut.opacity(0.7)))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(RoundedRectangle(cornerRadius: 8).fill(selected ? Theme.sage.opacity(0.28) : Color.clear))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(selected ? Theme.sage.opacity(0.7) : Color.clear, lineWidth: 1.5))
        .contentShape(Rectangle())
    }

    private func snippet(of text: String) -> String {
        let flat = text.replacingOccurrences(of: "\n", with: " ").trimmingCharacters(in: .whitespaces)
        return flat.count > 110 ? String(flat.prefix(110)) + "…" : flat
    }
}
