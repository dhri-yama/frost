import AppKit
import SwiftUI
import FrostCore

/// A menu bar item plus what the UI needs to draw it.
struct ItemRow: Identifiable {
    let item: MenuBarItem
    let icon: NSImage?
    var id: Int { item.id }
}

enum ScanSource { case accessibility, windowList }

/// Lists other apps' menu bar items for the Layout pane. Prefers the Accessibility scan; without the permission
/// (or if it finds nothing) it falls back to the window list, which needs no permission.
final class ItemsModel: ObservableObject {
    @Published var visible: [ItemRow] = []
    @Published var hidden: [ItemRow] = []
    @Published var trusted = AccessibilityScan.trusted
    @Published var source: ScanSource = .windowList
    @Published var scanning = false
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

    func refresh() {
        trusted = AccessibilityScan.trusted
        scanning = true
        let dividerX = dividerMinX(), dividerID = dividerWindowID(), own = ownWindowIDs()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let ax = AccessibilityScan.scan()
            let result: (visible: [MenuBarItem], hidden: [MenuBarItem], source: ScanSource)
            if !ax.isEmpty {
                let g = MenuBarScan.group(ax, dividerMinX: dividerX, ownPID: Int(getpid()))
                result = (g.visible, g.hidden, .accessibility)
            } else {
                let raw = (CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]]) ?? []
                let g = MenuBarScan.group(MenuBarScan.parse(raw), dividerWindowID: dividerID, ownWindowIDs: own)
                result = (g.visible, g.hidden, .windowList)
            }
            DispatchQueue.main.async {
                guard let self else { return }
                self.visible = result.visible.map(self.row); self.hidden = result.hidden.map(self.row)
                self.source = result.source; self.scanning = false
            }
        }
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
