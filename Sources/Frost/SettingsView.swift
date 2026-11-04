import SwiftUI
import FrostCore

enum Pane: String, CaseIterable {
    case general, about
    var title: String { rawValue.capitalized }
    var symbol: String { self == .general ? "gearshape.fill" : "info" }
    var blurb: String { self == .general ? "Theme, hiding and startup." : "Version and what Frost does with your data." }
}

/// Selected tab. An ObservableObject rather than @State: the Command Line Tools toolchain has no SwiftUI macro plugin.
final class PaneModel: ObservableObject { @Published var pane: Pane = .general }

struct SettingsView: View {
    @ObservedObject var store: SettingsStore
    @StateObject private var model = PaneModel()
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
