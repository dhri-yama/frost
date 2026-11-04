import Testing
@testable import FrostCore

@Suite struct ChevronPlacementTests {
    private func item(_ id: Int, _ name: String, x: Double, title: String? = nil, pid: Int? = nil) -> MenuBarItem {
        MenuBarItem(windowID: id, pid: pid ?? id, ownerName: name, minX: x, width: 24, title: title)
    }

    @Test func dropsJustInsideTheControlCenterItem() {
        let items = [item(1, "Dropbox", x: 900), item(2, "Control Center", x: 1100, title: "Wi-Fi"),
                     item(3, "Control Center", x: 1380, title: "Control Center"), item(4, "Clock", x: 1420)]
        #expect(ChevronPlacement.dropX(items: items, ownPID: 99) == 1381)
    }

    @Test func fallsBackToTheRightmostItem() {
        let items = [item(1, "Dropbox", x: 900), item(2, "Clock", x: 1420)]
        #expect(ChevronPlacement.dropX(items: items, ownPID: 99) == 1421)
    }

    @Test func ignoresFrostsOwnItemsAndHandlesNone() {
        #expect(ChevronPlacement.dropX(items: [item(1, "Frost", x: 1000, pid: 99)], ownPID: 99) == nil)
        #expect(ChevronPlacement.dropX(items: [], ownPID: 99) == nil)
    }
}
