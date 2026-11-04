import Testing
@testable import FrostCore

@Suite struct HideModeTests {
    private let running: Set<String> = ["com.dropbox", "com.docker", "com.slack", "com.apple.finder", "local.frost"]

    @Test func chosenModeHidesExactlyTheChosenApps() {
        let h = HiddenResolver.hidden(mode: .chosen, chosen: ["com.dropbox", "com.gone"], running: running, neverHide: ["local.frost"])
        #expect(h == ["com.dropbox", "com.gone"])    // an app that is not running stays in the list for when it launches
    }

    @Test func allExceptHidesEverythingRunningThatIsNotKept() {
        let h = HiddenResolver.hidden(mode: .allExcept, chosen: ["com.slack"], running: running, neverHide: ["local.frost"])
        #expect(h == ["com.dropbox", "com.docker"])  // not Slack (kept), not Frost, not Apple's own apps
    }

    @Test func allExceptNeverHidesFrostEvenIfItIsNotInTheKeepList() {
        let h = HiddenResolver.hidden(mode: .allExcept, chosen: [], running: ["local.frost", "com.a"], neverHide: ["local.frost"])
        #expect(h == ["com.a"])
    }

    @Test func chosenModeNeverHidesNeverHideApps() {
        let h = HiddenResolver.hidden(mode: .chosen, chosen: ["local.frost", "com.a"], running: running, neverHide: ["local.frost"])
        #expect(h == ["com.a"])
    }

    @Test func newlyLaunchedAppsAreHiddenInAllExceptMode() {
        var r = running
        #expect(!HiddenResolver.hidden(mode: .allExcept, chosen: [], running: r, neverHide: []).contains("com.new"))
        r.insert("com.new")
        #expect(HiddenResolver.hidden(mode: .allExcept, chosen: [], running: r, neverHide: []).contains("com.new"))
    }

    @Test func labelsAndRawValuesAreStable() {
        #expect(HideMode(rawValue: HideMode.allExcept.rawValue) == .allExcept)
        #expect(HideMode.allCases.map(\.label) == ["Apps I choose", "Everything except apps I choose"])
    }
}
