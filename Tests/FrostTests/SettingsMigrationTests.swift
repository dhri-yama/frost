import Testing
@testable import FrostCore

@Suite struct SettingsMigrationTests {
    @Test func copiesOnlyKeysTheNewDomainDoesNotHave() {
        let old: [String: Any] = ["themeName": "Paper", "autoHide": 30, "hideOnLaunch": false]
        let keys = SettingsMigration.keysToCopy(old: old, existing: ["autoHide"])
        #expect(keys == ["hideOnLaunch", "themeName"])
    }

    @Test func nothingToCopyFromAnEmptyOldDomain() {
        #expect(SettingsMigration.keysToCopy(old: [:], existing: ["a"]).isEmpty)
    }

    @Test func ignoresSystemKeys() {
        // Keys macOS writes into every app's domain are not Frost settings and must not be carried over.
        let old: [String: Any] = ["themeName": "Frost", "NSWindow Frame SettingsWindow": "0 0 720 600", "NSStatusItem Visible frost.toggle": true]
        #expect(SettingsMigration.keysToCopy(old: old, existing: []) == ["themeName"])
    }
}
