import SwiftUI
import Combine
import FrostCore

/// State for the search panel: the query, the highlighted row and the items to search.
final class SearchModel: ObservableObject {
    @Published var query = "" { didSet { selected = 0 } }
    @Published var selected = 0
    @Published var all: [ItemRow] = []
    @Published var hiddenIDs: Set<Int> = []

    var results: [ItemRow] {
        let byID = Dictionary(all.map { ($0.id, $0) }, uniquingKeysWith: { a, _ in a })
        return ItemSearch.filter(all.map(\.item), query: query).compactMap { byID[$0.id] }
    }

    func move(_ delta: Int) { selected = ItemSearch.move(selected: selected, count: results.count, by: delta) }
    var current: ItemRow? { let r = results; return r.indices.contains(selected) ? r[selected] : nil }
}

struct SearchView: View {
    @ObservedObject var model: SearchModel
    var trusted: Bool
    var onPick: (ItemRow) -> Void
    @FocusState private var focused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(Theme.textDim)
                TextField("Search menu bar items", text: $model.query)
                    .textFieldStyle(.plain).font(.system(size: 17)).foregroundStyle(Theme.ink)
                    .focused($focused)
                    .onSubmit { if let r = model.current { onPick(r) } }
                    .accessibilityLabel("Search menu bar items")
            }
            .padding(.horizontal, 16).frame(height: 52)
            Rectangle().fill(Theme.hairline).frame(height: 1)
            let rows = model.results
            if rows.isEmpty {
                Text(!trusted ? "Allow Accessibility in Settings to search your menu bar items." : (model.query.isEmpty ? "No items found." : "No match."))
                    .font(.system(size: 13)).foregroundStyle(Theme.textDim).frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(Array(rows.enumerated()), id: \.element.id) { i, r in
                            row(r, selected: i == model.selected).onTapGesture { onPick(r) }
                        }
                    }.padding(6)
                }
            }
        }
        .frame(width: 440, height: 380)
        .background { ZStack { Glass(material: Theme.style.material); Theme.glow } }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay { RoundedRectangle(cornerRadius: Theme.cardRadius).stroke(Theme.cardStroke, lineWidth: 1) }
        .environment(\.colorScheme, Theme.scheme)
        .onAppear { focused = true }
    }

    private func row(_ r: ItemRow, selected: Bool) -> some View {
        HStack(spacing: 12) {
            if let icon = r.icon { Image(nsImage: icon).resizable().frame(width: 22, height: 22) }
            else { Image(systemName: "app.dashed").frame(width: 22, height: 22).foregroundStyle(Theme.textDim) }
            VStack(alignment: .leading, spacing: 1) {
                Text(r.item.ownerName).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.ink)
                if let t = r.item.title, t != r.item.ownerName { Text(t).font(.system(size: 11)).foregroundStyle(Theme.textDim) }
            }
            Spacer()
            if model.hiddenIDs.contains(r.id) { Text("Hidden").font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.accent) }
        }
        .padding(.horizontal, 10).frame(height: 40)
        .background(selected ? Theme.ink(0.12) : .clear, in: RoundedRectangle(cornerRadius: Theme.controlRadius))
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
}

/// Owns the search window: shows it on a hotkey, handles arrow keys and Return, closes on Esc or a click elsewhere.
final class SearchController {
    private let items: ItemsModel
    private let activate: (ItemRow) -> Void
    private let model = SearchModel()
    private var window: PanelWindow?
    private var keyMonitor: Any?
    private var clickMonitor: Any?
    private var bag = Set<AnyCancellable>()

    init(items: ItemsModel, activate: @escaping (ItemRow) -> Void) {
        self.items = items
        self.activate = activate
        Publishers.CombineLatest(items.$hidden, items.$visible).receive(on: DispatchQueue.main).sink { [model] hidden, visible in
            model.hiddenIDs = Set(hidden.map(\.id))
            model.all = (hidden + visible).sorted { $0.item.minX < $1.item.minX }
        }.store(in: &bag)
    }

    func toggle() { window?.isVisible == true ? close() : show() }

    func show() {
        items.refresh()
        model.query = ""
        let host = NSHostingView(rootView: SearchView(model: model, trusted: AccessibilityScan.trusted) { [weak self] row in self?.pick(row) })
        let w = window ?? PanelWindow(content: host)
        w.contentView = host
        w.appearance = Theme.appearance
        window = w
        let vis = (NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        w.setFrame(NSRect(x: vis.midX - 220, y: vis.maxY - 380 - 80, width: 440, height: 380), display: true)
        NSApp.activate(ignoringOtherApps: true)
        w.makeKeyAndOrderFront(nil)
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] e in
            guard let self, self.window?.isVisible == true else { return e }
            switch e.keyCode {
            case 125: self.model.move(1); return nil     // down
            case 126: self.model.move(-1); return nil    // up
            default: return e
            }
        }
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in self?.close() }
    }

    private func pick(_ row: ItemRow) {
        close()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [activate] in activate(row) }
    }

    func close() {
        window?.orderOut(nil)
        if let m = keyMonitor { NSEvent.removeMonitor(m); keyMonitor = nil }
        if let m = clickMonitor { NSEvent.removeMonitor(m); clickMonitor = nil }
    }
}
