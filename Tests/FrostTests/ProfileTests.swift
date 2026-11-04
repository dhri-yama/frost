import Testing
import Foundation
@testable import FrostCore

@Suite struct ProfileTests {
    private func item(_ id: Int, _ name: String, x: Double) -> MenuBarItem {
        MenuBarItem(windowID: id, pid: id, ownerName: name, minX: x, width: 24)
    }

    @Test func capturingRecordsSortedUniqueOwners() {
        let p = Profile.capturing(name: "Work", hidden: [item(1, "Dropbox", x: -9), item(2, "Docker", x: -8), item(3, "Dropbox", x: -7)])
        #expect(p.name == "Work")
        #expect(p.hiddenOwners == ["Docker", "Dropbox"])
    }

    @Test func movesOnlyItemsOnTheWrongSide() {
        let items = [item(1, "Dropbox", x: 350), item(2, "Docker", x: -50), item(3, "Clock", x: 400), item(4, "Wi-Fi", x: -20)]
        let p = Profile(id: "a", name: "P", hiddenOwners: ["Dropbox", "Docker"])
        let moves = ProfilePlan.moves(items: items, profile: p, dividerMinX: 300)
        // Dropbox is visible but should be hidden; Clock is visible and stays; Wi-Fi is hidden but should show; Docker stays hidden.
        #expect(moves == [ProfileMove(id: 1, toHidden: true), ProfileMove(id: 4, toHidden: false)])
    }

    @Test func emptyProfileShowsEverythingHidden() {
        let items = [item(1, "A", x: -5), item(2, "B", x: 500)]
        let moves = ProfilePlan.moves(items: items, profile: Profile(id: "e", name: "All", hiddenOwners: []), dividerMinX: 300)
        #expect(moves == [ProfileMove(id: 1, toHidden: false)])
    }

    @Test func codableRoundTrip() throws {
        let p = Profile(id: "x", name: "Home", hiddenOwners: ["A", "B"])
        let data = try JSONEncoder().encode([p])
        #expect(try JSONDecoder().decode([Profile].self, from: data) == [p])
    }
}
