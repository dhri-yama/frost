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
