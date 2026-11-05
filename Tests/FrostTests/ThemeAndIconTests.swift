import Testing
@testable import FrostCore

@Suite struct ThemeNameTests {
    @Test func knownNamesAreKept() {
        #expect(ThemeName.resolve("Day") == "Day")
        #expect(ThemeName.resolve("Night") == "Night")
    }

    @Test func oldThemesMapToTheNearestNewOne() {
        #expect(ThemeName.resolve("Paper") == "Day")        // the old light theme
        #expect(ThemeName.resolve("Frost") == "Night")
        #expect(ThemeName.resolve("Midnight") == "Night")
        #expect(ThemeName.resolve("Mono") == "Night")
    }

    @Test func missingOrUnknownFallsBackToNight() {
        #expect(ThemeName.resolve(nil) == "Night")
        #expect(ThemeName.resolve("") == "Night")
        #expect(ThemeName.resolve("Neon") == "Night")
    }
}

@Suite struct MenuBarIconTests {
    @Test func everyIconHasALabelAndTwoSymbols() {
        for i in MenuBarIcon.allCases {
            #expect(!i.label.isEmpty)
            #expect(!i.symbol(collapsed: true).isEmpty && !i.symbol(collapsed: false).isEmpty)
        }
        #expect(Set(MenuBarIcon.allCases.map(\.label)).count == MenuBarIcon.allCases.count)
    }

    @Test func chevronPointsTheWayTheBarWillMove() {
        #expect(MenuBarIcon.chevron.symbol(collapsed: true) == "chevron.left")
        #expect(MenuBarIcon.chevron.symbol(collapsed: false) == "chevron.right")
    }

    @Test func resolvesSavedValuesAndDefaultsToChevron() {
        #expect(MenuBarIcon.resolve(rawValue: MenuBarIcon.glass.rawValue) == .glass)
        #expect(MenuBarIcon.resolve(rawValue: nil) == .chevron)
        #expect(MenuBarIcon.resolve(rawValue: 999) == .chevron)
    }
}
