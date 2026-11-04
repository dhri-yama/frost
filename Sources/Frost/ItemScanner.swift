import AppKit
import SwiftUI
import FrostCore

/// A menu bar item plus what the UI needs to draw it.
struct ItemRow: Identifiable {
    let item: MenuBarItem
    let icon: NSImage?
    var id: Int { item.id }
}

/// Lists other apps' menu bar items for the Layout pane. Reads the window list only; no permission needed.
final class ItemsModel: ObservableObject {
    @Published var visible: [ItemRow] = []
    @Published var hidden: [ItemRow] = []
    /// Window numbers of Frost's divider and its own items; set by the menu bar controller.
    var dividerWindowID: () -> Int = { -1 }
    var ownWindowIDs: () -> Set<Int> = { [] }

    func refresh() {
        let raw = (CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as? [[String: Any]]) ?? []
        let g = MenuBarScan.group(MenuBarScan.parse(raw), dividerWindowID: dividerWindowID(), ownWindowIDs: ownWindowIDs())
        visible = g.visible.map(row)
        hidden = g.hidden.map(row)
    }

    private func row(_ item: MenuBarItem) -> ItemRow {
        ItemRow(item: item, icon: NSRunningApplication(processIdentifier: pid_t(item.pid))?.icon)
    }
}
