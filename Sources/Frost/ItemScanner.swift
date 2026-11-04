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

    /// Everything found, left to right; used by `--scan`.
    var all: [ItemRow] { (hidden + visible).sorted { $0.item.minX < $1.item.minX } }

    private func row(_ item: MenuBarItem) -> ItemRow {
        ItemRow(item: item, icon: NSRunningApplication(processIdentifier: pid_t(item.pid))?.icon)
    }
}
