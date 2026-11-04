import Testing
@testable import FrostCore

@Suite struct ItemSearchTests {
    private func item(_ id: Int, _ name: String, title: String? = nil) -> MenuBarItem {
        MenuBarItem(windowID: id, pid: id, ownerName: name, minX: Double(id), width: 24, title: title)
    }
    private let items: [MenuBarItem] = []

    @Test func emptyQueryReturnsEverythingInOrder() {
        let all = [item(1, "Dropbox"), item(2, "Clock")]
        #expect(ItemSearch.filter(all, query: "  ").map(\.ownerName) == ["Dropbox", "Clock"])
    }

    @Test func matchesCaseInsensitivelyOnNameOrTitle() {
        let all = [item(1, "Control Center", title: "Wi-Fi"), item(2, "Dropbox"), item(3, "Clock")]
        #expect(ItemSearch.filter(all, query: "wifi").isEmpty)
        #expect(ItemSearch.filter(all, query: "WI-").map(\.ownerName) == ["Control Center"])
        #expect(ItemSearch.filter(all, query: "drop").map(\.ownerName) == ["Dropbox"])
    }

    @Test func ranksPrefixMatchesBeforeOthers() {
        let all = [item(1, "Unlock Pro"), item(2, "Black Hole"), item(3, "Lock")]
        // "lock": Lock (prefix) first, then names merely containing it, in original order
        #expect(ItemSearch.filter(all, query: "lock").map(\.ownerName) == ["Lock", "Unlock Pro", "Black Hole"])
    }

    @Test func nameMatchesBeatTitleMatches() {
        let all = [item(1, "Control Center", title: "Battery"), item(2, "Battery Monitor")]
        #expect(ItemSearch.filter(all, query: "batt").map(\.ownerName) == ["Battery Monitor", "Control Center"])
    }

    @Test func nextAndPreviousWrapAround() {
        #expect(ItemSearch.move(selected: 0, count: 3, by: -1) == 2)
        #expect(ItemSearch.move(selected: 2, count: 3, by: 1) == 0)
        #expect(ItemSearch.move(selected: 0, count: 0, by: 1) == 0)
    }
}
