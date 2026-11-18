import SwiftUI

/// The study-room window: a walnut top bar over either the cork board or the archive.
struct RootView: View {
    enum Tab: String, CaseIterable, Identifiable {
        case board = "Board"
        case archive = "Archive"
        var id: String { rawValue }
    }

    @State private var tab: Tab = .board

    var body: some View {
        VStack(spacing: 0) {
            TopBar(tab: $tab)
            Group {
                switch tab {
                case .board:   BoardView()
                case .archive: ArchiveView()
                }
            }
        }
        .frame(minWidth: 900, minHeight: 620)
        .background(Theme.walnut)
        .ignoresSafeArea(.container, edges: .top)     // the walnut bar sits under the transparent title bar
    }
}

/// A walnut plank across the top of the window, with paper tabs and a "New Note" button.
struct TopBar: View {
    @Binding var tab: RootView.Tab
    @EnvironmentObject private var manager: NoteManager

    var body: some View {
        HStack(spacing: 14) {
            Spacer().frame(width: 72)           // room for the window's traffic-light buttons
            Image(systemName: "leaf.fill").foregroundColor(Theme.sage.opacity(0.95))
            Text(AppConstants.appName)
                .font(Theme.serif(15))
                .foregroundColor(Theme.cream)
            Spacer()
            HStack(spacing: 6) {
                ForEach(RootView.Tab.allCases) { item in
                    tabButton(item)
                }
            }
            Spacer()
            Button {
                manager.addNote(text: "", color: NoteColor.allCases.randomElement() ?? .yellow)
                tab = .board
            } label: {
                Label("New Note", systemImage: "plus")
            }
            .buttonStyle(CozyButtonStyle(kind: .plain))
            .help("Pin a blank sticky note")
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(WoodSurface())
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color.black.opacity(0.45)).frame(height: 1)
        }
        .shadow(color: .black.opacity(0.45), radius: 6, x: 0, y: 3)
        .zIndex(1)
    }

    private func tabButton(_ item: RootView.Tab) -> some View {
        let selected = tab == item
        return Button { tab = item } label: {
            Text(item.rawValue)
                .font(Theme.serif(13))
                .foregroundColor(selected ? Theme.ink : Theme.cream.opacity(0.9))
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Capsule().fill(selected ? Theme.cream : Color.black.opacity(0.18)))
                .overlay(Capsule().strokeBorder(Theme.cream.opacity(selected ? 0 : 0.25), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}
