import SwiftUI
import FrostCore

enum Pane: String, CaseIterable {
    case general, layout, profiles, keys, about
    var title: String { rawValue.capitalized }
    var symbol: String {
        switch self { case .general: return "gearshape.fill"; case .layout: return "menubar.rectangle"; case .profiles: return "square.stack"; case .keys: return "command"; case .about: return "info" }
    }
    var blurb: String {
        switch self {
        case .general: return "Theme, hiding and startup."
        case .layout: return "Which icons are visible and which are tucked away."
        case .profiles: return "Save a layout and switch back to it in one click."
        case .keys: return "Global shortcuts that work from any app."
        case .about: return "Version and what Frost does with your data."
        }
    }
}

/// Selected tab. An ObservableObject rather than @State: the Command Line Tools toolchain has no SwiftUI macro plugin.
final class PaneModel: ObservableObject {
    @Published var pane: Pane
    @Published var newProfileName = ""
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
                    case .profiles: profiles
                    case .keys: keys
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
                        Image(systemName: p.symbol).font(.system(size: 18)).frame(height: 24)
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
                    MenuRow(title: "Reveal icons", subtitle: "What makes hidden icons appear. Hover waits a moment, and they hide again when the pointer leaves the menu bar.",
                            selection: $store.revealTrigger, options: RevealTrigger.allCases.map { ($0, $0.label) })
                    Sep()
                    MenuRow(title: "Show hidden items", subtitle: "A panel needs Accessibility access to click the items for you.",
                            selection: $store.revealMode, options: RevealMode.allCases.map { ($0, $0.label) })
                    Sep()
                    MenuRow(title: "Hide items again", subtitle: "How long revealed items stay visible.",
                            selection: $store.autoHide, options: AutoHide.allCases.map { ($0, $0.label) })
                    Sep()
                    ToggleRow(title: "Open at login", subtitle: store.loginError ?? "Start Frost when you log in.", isOn: $store.launchAtLogin)
                    Sep()
                    ToggleRow(title: "Presenting mode", subtitle: "Keep everything hidden, for screen sharing. ⌃⌥P toggles it.", isOn: $store.presenting)
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
            if items.needsInstall {
                Block(title: "Install") {
                    Row(title: "Move Frost to Applications",
                        subtitle: "On macOS 27 hiding only works when Frost runs from the Applications folder. Until then Frost cannot hide anything.") { EmptyView() }
                    Note("Quit Frost, copy Frost.app into /Applications (or run ./install.sh from the source folder), and open it from there.")
                }
            }
            if !items.trusted {
                Block(title: items.method == .allowList ? "Accessibility (optional)" : "Accessibility") {
                    Row(title: "Allow Accessibility access",
                        subtitle: items.method == .allowList
                            ? "Not needed to hide apps. It lets Frost list only apps that really have a menu bar item and click them for you. It cannot see your screen or what you type."
                            : "Lets Frost read which icons are in the menu bar so it can list and later arrange them. It cannot see your screen or what you type.") {
                        HStack(spacing: 8) {
                            Button("Allow") { AccessibilityScan.requestTrust() }.buttonStyle(ControlButton(primary: true))
                            Button("Open Settings") { AccessibilityScan.openSettings() }.buttonStyle(ControlButton())
                        }
                    }
                    Note(items.method == .allowList ? "Without it Frost lists every running app instead. After allowing it, press Refresh." : "Without it Frost falls back to a less complete scan. After allowing it, press Refresh.")
                }
            }
            Block(title: "Hidden (\(items.hidden.count))") {
                if items.hidden.isEmpty {
                    Note(items.method == .allowList ? "Nothing is hidden. Press Hide on an app below." : "Nothing is hidden. ⌘-drag icons to the left of Frost's divider (|) to hide them.")
                } else {
                    Card { ForEach(Array(items.hidden.enumerated()), id: \.element.id) { i, r in if i > 0 { Sep() }; itemRow(r, hidden: true) } }
                    Note("These are off-screen while Frost is collapsed. Click the chevron to reveal them.")
                }
            }
            Block(title: "Visible (\(items.visible.count))") {
                if items.visible.isEmpty && items.hidden.isEmpty {
                    Note(items.trusted ? "Frost could not find any items. Run Frost with --scan in a terminal for details." : "Allow Accessibility access above so Frost can find your menu bar items.")
                }
                Card { ForEach(Array(items.visible.enumerated()), id: \.element.id) { i, r in if i > 0 { Sep() }; itemRow(r, hidden: false) } }
            }
            HStack(spacing: 12) {
                Button("Refresh") { items.refresh() }.buttonStyle(ControlButton())
                if items.scanning { Text("Scanning…").font(.system(size: 12)).foregroundStyle(Theme.textDim) }
                Spacer()
            }
            Note("Found using \(items.source == .accessibility ? "Accessibility" : (items.source == .runningApps ? "the list of running apps" : "the window list")). Frost never changes other apps' icons, only whether they show.")
            if items.moving { Note("Moving the icon… keep the mouse still for a moment.") }
            if items.moveFailed { Note("That item could not be moved. Some system items, like the clock, cannot be rearranged. Try ⌘-dragging it by hand.") }
        }
    }

    private func itemRow(_ r: ItemRow, hidden: Bool) -> some View {
        Row(title: r.item.ownerName, subtitle: r.item.title.flatMap { $0 == r.item.ownerName ? nil : $0 }) {
            HStack(spacing: 12) {
                if let icon = r.icon { Image(nsImage: icon).resizable().frame(width: 22, height: 22) }
                else { Image(systemName: "app.dashed").font(.system(size: 16)).foregroundStyle(Theme.textDim) }
                if items.method == .allowList ? r.item.bundleID != nil : items.source == .accessibility {
                    Button(hidden ? "Show" : "Hide") { toggle(r, hidden: hidden) }
                        .buttonStyle(ControlButton())
                        .frame(width: 64)
                        .disabled(items.moving).opacity(items.moving ? 0.4 : 1)
                        .accessibilityLabel("\(hidden ? "Show" : "Hide") \(r.item.ownerName)")
                }
            }
        }
    }

    /// With the allow-list, hiding is a setting on the app; with the divider, it is a drag across it.
    private func toggle(_ r: ItemRow, hidden: Bool) {
        if items.method == .allowList, let id = r.item.bundleID {
            store.toggleHidden(id)
            items.refresh()
        } else {
            items.move(r, toHidden: !hidden)
        }
    }

    private var profiles: some View {
        VStack(alignment: .leading, spacing: 28) {
            Block(title: "Saved layouts") {
                if store.profiles.isEmpty {
                    Note("No saved layouts yet. Arrange your menu bar, then save it below.")
                } else {
                    Card {
                        ForEach(Array(store.profiles.enumerated()), id: \.element.id) { i, p in
                            if i > 0 { Sep() }
                            Row(title: p.name, subtitle: p.hiddenOwners.isEmpty ? "Nothing hidden" : "Hides \(p.hiddenOwners.joined(separator: ", "))") {
                                HStack(spacing: 8) {
                                    Button("Apply") { applyProfile(p) }.buttonStyle(ControlButton(primary: true))
                                        .disabled(!canApply).opacity(canApply ? 1 : 0.4)
                                    Button("Delete") { store.profiles.removeAll { $0.id == p.id } }.buttonStyle(ControlButton())
                                }
                            }
                        }
                    }
                    if !canApply { Note("Applying a layout needs Accessibility access. Allow it in the Layout tab.") }
                }
            }
            Block(title: "Save current layout") {
                Row(title: "Name", subtitle: "Saves which apps are hidden right now (\(items.hidden.count)).") {
                    HStack(spacing: 8) {
                        nameField
                            .textFieldStyle(.plain).font(.system(size: 13)).foregroundStyle(Theme.ink)
                            .padding(.horizontal, 10).frame(width: 150, height: Control.height)
                            .background(Control.fill, in: RoundedRectangle(cornerRadius: Control.radius))
                            .accessibilityLabel("Layout name")
                        Button("Save") { saveProfile() }.buttonStyle(ControlButton(primary: true))
                            .disabled(model.newProfileName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                Note(items.method == .allowList ? "Applying a layout changes which apps are hidden straight away." : "Applying a layout drags icons across Frost's divider one at a time. Keep the mouse still until it finishes.")
            }
        }
    }

    /// ImageRenderer cannot draw a TextField, so snapshots show static placeholder text instead.
    @ViewBuilder private var nameField: some View {
        if Theme.snapshot { Text("Work").foregroundStyle(Theme.textDim).frame(maxWidth: .infinity, alignment: .leading) }
        else { TextField("Work", text: $model.newProfileName) }
    }

    private var canApply: Bool { !items.moving && (items.method == .allowList || items.source == .accessibility) }

    private func applyProfile(_ p: Profile) {
        if items.method == .allowList {
            store.hiddenBundleIDs = Set(p.hiddenBundleIDs)
            items.refresh()
        } else {
            items.apply(p)
        }
    }

    private func saveProfile() {
        let name = model.newProfileName.trimmingCharacters(in: .whitespaces)
        guard !name.isEmpty else { return }
        store.profiles.append(Profile.capturing(name: name, hidden: items.hidden.map(\.item)))
        model.newProfileName = ""
    }

    private var keys: some View {
        Block(title: "Shortcuts") {
            Card {
                ToggleRow(title: "Enable global shortcuts", subtitle: "Turn off if they clash with another app.", isOn: $store.shortcutsEnabled)
                Sep()
                shortcut("Show or hide items", "⌃⌥H")
                Sep()
                shortcut("Search menu bar items", "⌃⌥Space")
                Sep()
                shortcut("Presenting mode", "⌃⌥P")
            }
            Note("Search lists every item, hidden or not. Type to filter, ↑ ↓ to choose, Return to click it, Esc to close. Clicking needs Accessibility access.")
        }
    }

    private func shortcut(_ title: String, _ keys: String) -> some View {
        Row(title: title) { Text(keys).font(.system(size: 13, weight: .medium, design: .monospaced)).foregroundStyle(Theme.ink)
            .padding(.horizontal, 10).frame(height: Control.height).background(Control.fill, in: RoundedRectangle(cornerRadius: Control.radius)) }
    }

    private var about: some View {
        Block(title: "Frost") {
            Card {
                Row(title: "Version", subtitle: "Semantic versioning; see the changelog for what changed.") {
                    Text(AppInfo.version).font(.system(size: 13, weight: .medium, design: .monospaced)).foregroundStyle(Theme.ink)
                }
                Sep()
                Row(title: "Hiding method", subtitle: items.method == .allowList
                        ? "System allow-list (private macOS API). Hides whole apps; the Focus and camera indicators are hidden while it is on."
                        : "Divider. Icons left of the divider are pushed off the edge of the menu bar.") { EmptyView() }
                Sep()
                Row(title: "Privacy", subtitle: "No accounts, no telemetry, no network calls. Settings stay on this Mac.") { EmptyView() }
            }
        }
    }
}
