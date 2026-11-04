import Testing
import Foundation
@testable import FrostCore

@Suite struct ShortcutTests {
    @Test func defaultsAreDistinctAndValid() {
        let all = ShortcutAction.allCases.map(\.defaultShortcut)
        #expect(Set(all.map { "\($0.keyCode)-\($0.modifiers)" }).count == all.count)
        #expect(all.allSatisfy { $0.isValid })
    }

    @Test func displayOrdersModifiersAndNamesKeys() {
        #expect(ShortcutAction.toggle.defaultShortcut.display == "⌃⌥H")
        #expect(ShortcutAction.search.defaultShortcut.display == "⌃⌥Space")
        #expect(Shortcut(keyCode: 123, modifiers: Shortcut.command | Shortcut.shift | Shortcut.control | Shortcut.option).display == "⌃⌥⇧⌘←")
    }

    @Test func needsAModifierAndAKnownKey() {
        #expect(!Shortcut(keyCode: 4, modifiers: 0).isValid)                       // H alone
        #expect(!Shortcut(keyCode: 4, modifiers: Shortcut.shift).isValid)          // shift alone is not enough
        #expect(!Shortcut(keyCode: 250, modifiers: Shortcut.control).isValid)      // unknown key
        #expect(Shortcut(keyCode: 4, modifiers: Shortcut.command).isValid)
    }

    @Test func conflictsAreFoundAgainstOtherActionsOnly() {
        var set = ShortcutSet()
        let mine = set[.toggle]
        #expect(set.conflict(for: mine, action: .toggle) == nil)                   // not a conflict with itself
        #expect(set.conflict(for: ShortcutAction.search.defaultShortcut, action: .toggle) == .search)
        set[.toggle] = Shortcut(keyCode: 0, modifiers: Shortcut.command)
        #expect(set.conflict(for: Shortcut(keyCode: 0, modifiers: Shortcut.command), action: .presenting) == .toggle)
    }

    @Test func setRoundTripsAndFillsMissingActionsWithDefaults() throws {
        var set = ShortcutSet()
        set[.search] = Shortcut(keyCode: 1, modifiers: Shortcut.command)
        let decoded = try JSONDecoder().decode(ShortcutSet.self, from: try JSONEncoder().encode(set))
        #expect(decoded[.search] == set[.search])
        let partial = try JSONDecoder().decode(ShortcutSet.self, from: #"{"search":{"keyCode":1,"modifiers":256}}"#.data(using: .utf8)!)
        #expect(partial[.toggle] == ShortcutAction.toggle.defaultShortcut)         // missing ones fall back
        #expect(partial[.search].keyCode == 1)
    }
}
