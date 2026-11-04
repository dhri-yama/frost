import Testing
@testable import FrostCore

private func win(_ id: Int, _ owner: String, x: Double, w: Double = 24, layer: Int = 25, h: Double = 24, pid: Int = 100) -> [String: Any] {
    ["kCGWindowNumber": id, "kCGWindowOwnerPID": pid, "kCGWindowOwnerName": owner, "kCGWindowLayer": layer,
     "kCGWindowBounds": ["X": x, "Y": 0.0, "Width": w, "Height": h]]
}

@Suite struct MenuBarScanTests {
    @Test func keepsOnlyStatusItemWindowsSortedLeftToRight() {
        let items = MenuBarScan.parse([
            win(1, "Clock", x: 1400), win(2, "Dropbox", x: 1200), win(3, "Some Window", x: 10, layer: 0),
            win(4, "Wallpaper", x: 0, w: 3000, h: 900),
        ])
        #expect(items.map(\.ownerName) == ["Dropbox", "Clock"])
    }

    @Test func skipsMalformedEntries() {
        #expect(MenuBarScan.parse([["kCGWindowLayer": 25], [:]]).isEmpty)
    }

    @Test func groupsByDividerPosition() {
        let items = MenuBarScan.parse([
            win(10, "Hidden App", x: -9000), win(11, "Other Hidden", x: -9100),
            win(20, "Frost", x: 1300, w: 18, pid: 1), win(21, "Frost", x: 1330, pid: 1),
            win(30, "Visible App", x: 1380),
        ])
        let g = MenuBarScan.group(items, dividerWindowID: 20, ownWindowIDs: [20, 21])
        #expect(g.hidden.map(\.ownerName) == ["Hidden App", "Other Hidden"] || g.hidden.map(\.ownerName) == ["Other Hidden", "Hidden App"])
        #expect(g.visible.map(\.ownerName) == ["Visible App"])
    }

    @Test func withoutDividerEverythingIsVisible() {
        let items = MenuBarScan.parse([win(1, "A", x: 100), win(2, "B", x: 200)])
        let g = MenuBarScan.group(items, dividerWindowID: 99, ownWindowIDs: [])
        #expect(g.hidden.isEmpty && g.visible.count == 2)
    }
}

@Suite struct PositionGroupingTests {
    private func item(_ id: Int, _ name: String, x: Double, pid: Int, title: String? = nil) -> MenuBarItem {
        MenuBarItem(windowID: id, pid: pid, ownerName: name, minX: x, width: 24, title: title)
    }

    @Test func groupsByDividerPositionAndDropsOwnItems() {
        let items = [item(1, "Dropbox", x: -5000, pid: 10), item(2, "Frost", x: 1300, pid: 1), item(3, "Clock", x: 1400, pid: 20)]
        let g = MenuBarScan.group(items, dividerMinX: 1300, ownPID: 1)
        #expect(g.hidden.map(\.ownerName) == ["Dropbox"])
        #expect(g.visible.map(\.ownerName) == ["Clock"])
    }

    @Test func noDividerMeansNothingHidden() {
        let g = MenuBarScan.group([item(1, "A", x: 5, pid: 10)], dividerMinX: nil, ownPID: 1)
        #expect(g.hidden.isEmpty && g.visible.count == 1)
    }

    @Test func titleIsOptionalAndDefaultsToNil() {
        #expect(MenuBarItem(windowID: 1, pid: 1, ownerName: "A", minX: 0, width: 1).title == nil)
    }
}

@Suite struct SystemItemTests {
    @Test func appleAppsAreSystemItems() {
        let apple = MenuBarItem(windowID: 1, pid: 1, ownerName: "Control Center", minX: 0, width: 24, bundleID: "com.apple.controlcenter")
        let other = MenuBarItem(windowID: 2, pid: 2, ownerName: "Dropbox", minX: 0, width: 24, bundleID: "com.getdropbox.dropbox")
        let unknown = MenuBarItem(windowID: 3, pid: 3, ownerName: "?", minX: 0, width: 24)
        #expect(apple.isSystemItem && !other.isSystemItem && !unknown.isSystemItem)
    }
}
