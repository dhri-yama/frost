import Testing
import Foundation
@testable import FrostCore

@Suite struct AllowListTests {
    @Test func firstApplyIsNeeded() {
        #expect(AllowList().needsApply(hidden: ["a"], allowed: ["b"]))
    }

    @Test func identicalApplyIsSkipped() {
        var l = AllowList()
        l.record(hidden: ["a"], allowed: ["b", "c"])
        #expect(!l.needsApply(hidden: ["a"], allowed: ["b", "c"]))
    }

    @Test func newlyLaunchedAllowedAppNeedsApply() {
        var l = AllowList()
        l.record(hidden: ["a"], allowed: ["b"])
        #expect(l.needsApply(hidden: ["a"], allowed: ["b", "new"]))
    }

    @Test func quitAllowedAppDoesNotNeedApply() {
        var l = AllowList()
        l.record(hidden: ["a"], allowed: ["b", "c"])
        #expect(!l.needsApply(hidden: ["a"], allowed: ["b"]))
    }

    @Test func changedHiddenSetNeedsApplyAndClearForgets() {
        var l = AllowList()
        l.record(hidden: ["a"], allowed: ["b"])
        #expect(l.needsApply(hidden: ["a", "b"], allowed: []))
        l.clear()
        #expect(l.needsApply(hidden: ["a"], allowed: ["b"]))
    }
}

@Suite struct BundleGroupingTests {
    private func item(_ id: Int, _ name: String, bundle: String?) -> MenuBarItem {
        MenuBarItem(windowID: id, pid: id, ownerName: name, minX: Double(id), width: 24, bundleID: bundle)
    }

    @Test func groupsByHiddenBundleIDsAndDropsOwnPID() {
        let items = [item(1, "Dropbox", bundle: "com.dropbox"), item(2, "Frost", bundle: "local.frost"),
                     item(3, "Clock", bundle: nil), item(4, "Docker", bundle: "com.docker")]
        let g = MenuBarScan.group(items, hiddenBundleIDs: ["com.dropbox", "com.docker"], ownPID: 2)
        #expect(g.hidden.map(\.ownerName) == ["Dropbox", "Docker"])
        #expect(g.visible.map(\.ownerName) == ["Clock"])
    }

    @Test func profilesCaptureAndDecodeBundleIDs() throws {
        let p = Profile.capturing(name: "W", hidden: [item(1, "Dropbox", bundle: "com.dropbox"), item(2, "X", bundle: nil)])
        #expect(p.hiddenBundleIDs == ["com.dropbox"])
        // Profiles saved by older versions have no bundle IDs and must still load.
        let old = #"[{"id":"1","name":"Old","hiddenOwners":["A"]}]"#.data(using: .utf8)!
        let decoded = try JSONDecoder().decode([Profile].self, from: old)
        #expect(decoded.first?.hiddenBundleIDs == [] && decoded.first?.hiddenOwners == ["A"])
    }
}
