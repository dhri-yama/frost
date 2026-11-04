import AppKit
import SwiftUI
import FrostCore

/// A menu bar item plus what the UI needs to draw it.
struct ItemRow: Identifiable {
    let item: MenuBarItem
    let icon: NSImage?
    var id: Int { item.id }
}

enum ScanSource { case accessibility, windowList, runningApps }

/// Lists other apps' menu bar items for the Layout pane. Prefers the Accessibility scan; without the permission
/// (or if it finds nothing) it falls back to the window list, which needs no permission.
final class ItemsModel: ObservableObject {
    @Published var visible: [ItemRow] = []
    @Published var hidden: [ItemRow] = []
    @Published var trusted = AccessibilityScan.trusted
    @Published var source: ScanSource = .windowList
    @Published var scanning = false
    /// How hiding works here, and whether Frost must be moved to /Applications first. Set by the app delegate.
    @Published var method: HideMethod = .divider
    @Published var needsInstall = false
    /// The system's error if it refused the latest allow-list; nil when hiding is working.
    @Published var restrictionError: String?
    var hiddenBundleIDs: () -> Set<String> = { [] }
    @Published var moving = false
    @Published var moveFailed = false
    var prepareForMove: () -> Void = {}
    var finishMove: () -> Void = {}
    var toggleMinX: () -> Double? = { nil }
    var barY: () -> Double? = { nil }
    /// Left edge of Frost's divider in screen coordinates, set by the menu bar controller.
    var dividerMinX: () -> Double? = { nil }
    /// Window numbers of Frost's divider and its own items, used by the window-list fallback.
    var dividerWindowID: () -> Int = { -1 }
    var ownWindowIDs: () -> Set<Int> = { [] }

    /// Bumped on every refresh so a slow, older scan cannot overwrite the result of a newer one.
    private var refreshToken = 0

    func refresh() {
        trusted = AccessibilityScan.trusted
        scanning = true
        refreshToken += 1
        let token = refreshToken
        let dividerX = dividerMinX(), dividerID = dividerWindowID(), own = ownWindowIDs()
        let method = self.method, hiddenIDs = hiddenBundleIDs()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let ax = AccessibilityScan.scan()
            var result: (visible: [MenuBarItem], hidden: [MenuBarItem], source: ScanSource)
            if method == .allowList {
                // Hiding is per app, so which side an item is on comes from Frost's own list, not from its position.
                var found = ax, source = ScanSource.accessibility
                if found.isEmpty { found = Self.runningApps(); source = .runningApps }
                let g = MenuBarScan.group(found, hiddenBundleIDs: hiddenIDs, ownPID: Int(getpid()))
                // Hidden apps may have no item to scan while hidden; keep them listed so they can be shown again.
                let known = Set(g.hidden.compactMap(\.bundleID))
                let missing = Self.runningApps().filter { m in m.bundleID.map { hiddenIDs.contains($0) && !known.contains($0) } ?? false }
                result = (g.visible, g.hidden + missing, source)
            } else if !ax.isEmpty {
                let g = MenuBarScan.group(ax, dividerMinX: dividerX, ownPID: Int(getpid()))
                result = (g.visible, g.hidden, .accessibility)
            } else {
                let raw = (CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]]) ?? []
                let g = MenuBarScan.group(MenuBarScan.parse(raw), dividerWindowID: dividerID, ownWindowIDs: own)
                result = (g.visible, g.hidden, .windowList)
            }
            DispatchQueue.main.async {
                guard let self, token == self.refreshToken else { return }
                self.visible = result.visible.map(self.row); self.hidden = result.hidden.map(self.row)
                self.source = result.source; self.scanning = false
            }
        }
    }

    /// Running apps that could own a menu bar item, for when Accessibility cannot list real items. Apple background
    /// agents are left out. Ids are `pid * 1000`.
    private static func runningApps() -> [MenuBarItem] {
        NSWorkspace.shared.runningApplications
            .filter { $0.activationPolicy != .prohibited && $0.bundleIdentifier != nil && !($0.bundleIdentifier ?? "").hasPrefix("com.apple.") }
            .map { MenuBarItem(windowID: Int($0.processIdentifier) * 1000, pid: Int($0.processIdentifier), ownerName: $0.localizedName ?? "Unknown",
                               minX: 0, width: 0, bundleID: $0.bundleIdentifier) }
            .sorted { $0.ownerName.localizedCaseInsensitiveCompare($1.ownerName) == .orderedAscending }
    }

    /// Moves an item to the hidden or visible side. Expands the bar, drags, then restores it and rescans.
    func move(_ row: ItemRow, toHidden: Bool) {
        guard !moving else { return }
        moving = true; moveFailed = false
        prepareForMove()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            // Positions shift once the divider shrinks, so read the geometry after the wait.
            var ok = false
            DispatchQueue.main.sync {
                if let d = self.dividerMinX(), let t = self.toggleMinX(), let y = self.barY() {
                    DispatchQueue.global(qos: .userInitiated).async {
                        ok = ItemMover.move(id: row.id, toHidden: toHidden, dividerMinX: d, toggleMinX: t, barY: y)
                        usleep(400_000)
                        DispatchQueue.main.async { self.endMove(ok) }
                    }
                } else { self.endMove(false) }
            }
        }
    }

    /// Makes the menu bar match a profile: moves each item that is on the wrong side, one at a time. Positions shift
    /// after every move, so the geometry is read again before each one. Each item is tried once.
    func apply(_ profile: Profile) {
        guard !moving else { return }
        moving = true; moveFailed = false
        prepareForMove()
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self else { return }
            var tried = Set<Int>(), failures = 0
            for _ in 0..<40 {
                var geo: (Double, Double, Double)?
                DispatchQueue.main.sync {
                    if let d = self.dividerMinX(), let t = self.toggleMinX(), let y = self.barY() { geo = (d, t, y) }
                }
                guard let (d, t, y) = geo else { failures += 1; break }
                let others = AccessibilityScan.scan().filter { $0.pid != Int(getpid()) }
                guard let m = ProfilePlan.moves(items: others, profile: profile, dividerMinX: d).first(where: { !tried.contains($0.id) }) else { break }
                tried.insert(m.id)
                if !ItemMover.move(id: m.id, toHidden: m.toHidden, dividerMinX: d, toggleMinX: t, barY: y) { failures += 1 }
                usleep(400_000)
            }
            DispatchQueue.main.async { self.endMove(failures == 0) }
        }
    }

    private func endMove(_ ok: Bool) {
        finishMove()
        moving = false; moveFailed = !ok
        // Give the bar a moment to settle after collapsing before reading positions again.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in self?.refresh() }
    }

    /// Everything found, left to right; used by `--scan`.
    var all: [ItemRow] { (hidden + visible).sorted { $0.item.minX < $1.item.minX } }

    private func row(_ item: MenuBarItem) -> ItemRow {
        ItemRow(item: item, icon: NSRunningApplication(processIdentifier: pid_t(item.pid))?.icon)
    }
}
