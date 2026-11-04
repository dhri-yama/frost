import SwiftUI
import FrostCore

enum Pane: String, CaseIterable {
    case general, layout, about
    var title: String { rawValue.capitalized }
    var symbol: String {
        switch self { case .general: return "gearshape.fill"; case .layout: return "menubar.rectangle"; case .about: return "info" }
    }
    var blurb: String {
        switch self {
        case .general: return "Theme, hiding and startup."
        case .layout: return "Which icons are visible and which are tucked away."
        case .about: return "Version and what Frost does with your data."
        }
    }
}

/// Selected tab. An ObservableObject rather than @State: the Command Line Tools toolchain has no SwiftUI macro plugin.
final class PaneModel: ObservableObject {
    @Published var pane: Pane
    init(_ pane: Pane = .general) { self.pane = pane }
}

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @ObservedObject var items: ItemsModel
    @StateObject private var model: PaneModel
    init(store: SettingsStore, items: ItemsModel, initialPane: Pane = .general) {
        self.store = store; self.items = items
        _model = StateObject(wrappedValue: PaneModel(initialPane))
    }
    private var pane: Pane { model.pane }

    var body: some View {
        VStack(spacing: 0) {
            toolbar
            Rectangle().fill(Theme.hairline).frame(height: 1)
            scrolling {
                VStack(alignment: .leading, spacing: 28) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(pane.title).font(Theme.display(38, .bold)).foregroundStyle(Theme.ink)
                        Text(pane.blurb).font(.system(size: 15)).foregroundStyle(Theme.textDim)
                    }
                    switch pane {
                    case .general: general
                    case .layout: layout
                    case .about: about
                    }
                }
                .padding(.horizontal, 48).padding(.vertical, 36)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 720, height: 600)
        .background { ZStack { if !Theme.snapshot { Glass(material: Theme.style.material) }; Theme.glow }.ignoresSafeArea() }
        .environment(\.colorScheme, Theme.scheme)
        .onAppear { if !Theme.snapshot { items.refresh() } }
        .id(store.themeName)   // rebuild every surface when the theme changes
    }

    @ViewBuilder private func scrolling<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        if Theme.snapshot { content().frame(maxHeight: .infinity, alignment: .top) } else { ScrollView { content() } }
    }

    private var toolbar: some View {
        HStack(spacing: 6) {
            ForEach(Pane.allCases, id: \.self) { p in
                Button { model.pane = p } label: {
                    VStack(spacing: 4) {
                        Image(systemName: p.symbol).font(.system(size: 18))
                        Text(p.title).font(.system(size: 12, weight: .medium))
                        Capsule().fill(pane == p ? Theme.accent : .clear).frame(width: 22, height: 2)
                    }
                    .foregroundStyle(pane == p ? Theme.ink : Theme.textDim)
                    .frame(width: 84)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(p.title)
            }
        }
        .padding(.top, 34).padding(.bottom, 8)
    }

    private var general: some View {
        VStack(alignment: .leading, spacing: 28) {
            Block(title: "Theme") {
                HStack(spacing: 14) {
                    ForEach(Style.all, id: \.name) { s in
                        Button { store.themeName = s.name } label: {
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 14).fill(Theme.swatch(s)).frame(width: 120, height: 78)
                                    .overlay(alignment: .topLeading) {
                                        Text("Aa").font(.system(size: 22, weight: .bold, design: s.displayDesign)).foregroundStyle(s.ink).padding(10)
                                    }
                                    .overlay(alignment: .bottomLeading) {
                                        Capsule().fill(s.accent).frame(width: 30, height: 8).padding(10)
                                    }
                                    .overlay { RoundedRectangle(cornerRadius: 14).stroke(store.themeName == s.name ? s.accent : .clear, lineWidth: 3) }
                                Text(s.name).font(.system(size: 13, weight: store.themeName == s.name ? .semibold : .regular)).foregroundStyle(Theme.ink)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(s.name) theme")
                    }
                }
                Note("Applies everywhere in Frost. It never changes the look of other apps' menu bar icons.").padding(.top, 6)
            }
            Block(title: "Hiding") {
                Card {
                    MenuRow(title: "Hide items again", subtitle: "How long revealed items stay visible.",
                            selection: $store.autoHide, options: AutoHide.allCases.map { ($0, $0.label) })
                    Sep()
                    ToggleRow(title: "Hide items at launch", subtitle: "Start with everything left of the divider hidden.", isOn: $store.hideOnLaunch)
                }
            }
            Block(title: "Setup") {
                Note("Hold ⌘ and drag icons in the menu bar to place them left of Frost's divider (|) to hide them, or right of it to keep them visible. Automatic arranging arrives in a later version.")
            }
        }
    }

    private var layout: some View {
        VStack(alignment: .leading, spacing: 28) {
            Block(title: "Hidden (\(items.hidden.count))") {
                if items.hidden.isEmpty {
                    Note("Nothing is hidden. ⌘-drag icons to the left of Frost's divider (|) to hide them.")
                } else {
                    Card { ForEach(Array(items.hidden.enumerated()), id: \.element.id) { i, r in if i > 0 { Sep() }; itemRow(r) } }
                    Note("These are off-screen while Frost is collapsed. Click the chevron to reveal them.")
                }
            }
            Block(title: "Visible (\(items.visible.count))") {
                if items.visible.isEmpty && items.hidden.isEmpty {
                    Note("Frost could not find any items. Newer macOS versions may not list other apps' menu bar items in the window list; an Accessibility-based scan is planned. Run Frost with --scan for details.")
                }
                Card { ForEach(Array(items.visible.enumerated()), id: \.element.id) { i, r in if i > 0 { Sep() }; itemRow(r) } }
            }
            HStack { Button("Refresh") { items.refresh() }.buttonStyle(ControlButton()); Spacer() }
            Note("Frost reads the window list to find these items. It needs no permission and never changes other apps' icons. Moving items from here arrives in a later version.")
        }
    }

    private func itemRow(_ r: ItemRow) -> some View {
        Row(title: r.item.ownerName) {
            Group {
                if let icon = r.icon { Image(nsImage: icon).resizable().frame(width: 22, height: 22) }
                else { Image(systemName: "app.dashed").font(.system(size: 16)).foregroundStyle(Theme.textDim) }
            }
        }
    }

    private var about: some View {
        Block(title: "Frost") {
            Card {
                Row(title: "Version", subtitle: "Semantic versioning; see the changelog for what changed.") {
                    Text(AppInfo.version).font(.system(size: 13, weight: .medium, design: .monospaced)).foregroundStyle(Theme.ink)
                }
                Sep()
                Row(title: "Privacy", subtitle: "No accounts, no telemetry, no network calls. Settings stay on this Mac.") { EmptyView() }
            }
        }
    }
}
