import Testing
@testable import FrostCore

@Suite struct RevealTriggerTests {
    @Test func flagsMatchTheChoice() {
        #expect(RevealTrigger.click.onClick && !RevealTrigger.click.onHover)
        #expect(!RevealTrigger.hover.onClick && RevealTrigger.hover.onHover)
        #expect(RevealTrigger.both.onClick && RevealTrigger.both.onHover)
    }

    @Test func labelsAreDistinctAndRoundTrip() {
        #expect(Set(RevealTrigger.allCases.map(\.label)).count == 3)
        #expect(RevealTrigger(rawValue: RevealTrigger.both.rawValue) == .both)
    }
}

@Suite struct HoverZoneTests {
    private let bar = HoverBox(minX: 0, minY: 923, maxX: 1470, maxY: 956)      // menu bar strip, bottom-left origin
    private let panel = HoverBox(minX: 700, minY: 800, maxX: 1000, maxY: 880)

    @Test func insideTheMenuBarKeepsItRevealed() {
        #expect(HoverZone.keepsRevealed(x: 300, y: 940, boxes: [bar]))
    }

    @Test func belowTheBarEndsItUnlessOnThePanel() {
        #expect(!HoverZone.keepsRevealed(x: 300, y: 700, boxes: [bar]))
        #expect(HoverZone.keepsRevealed(x: 800, y: 850, boxes: [bar, panel]))
    }

    @Test func boxesAreSlightlyForgiving() {
        // A few points outside still counts, so a pointer that clips the edge does not hide the icons.
        #expect(HoverZone.keepsRevealed(x: 300, y: 920, boxes: [bar]))
        #expect(!HoverZone.keepsRevealed(x: 300, y: 900, boxes: [bar]))
    }
}

@Suite struct TriggerZoneTests {
    // Screen 1470 wide, menu bar strip y 923...956 (bottom-left origin), chevron at x 1300...1338.
    private func boxes(leftmost: Double?) -> [HoverBox] {
        HoverZone.triggerBoxes(screenMinX: 0, screenMaxX: 1470, barMinY: 923, barMaxY: 956,
                               chevronMinX: 1300, chevronMaxX: 1338, leftmostVisibleMinX: leftmost)
    }

    @Test func emptySpaceRunsFromScreenMiddleToTheLeftmostVisibleIcon() {
        let b = boxes(leftmost: 1100)
        #expect(HoverZone.keepsRevealed(x: 900, y: 940, boxes: b))           // empty space
        #expect(!HoverZone.keepsRevealed(x: 400, y: 940, boxes: b))          // app menus side
        #expect(!HoverZone.keepsRevealed(x: 1200, y: 940, boxes: b))         // over a visible icon
    }

    @Test func withoutIconPositionsTheZoneEndsAtTheChevron() {
        let b = boxes(leftmost: nil)
        #expect(HoverZone.keepsRevealed(x: 1250, y: 940, boxes: b))
        #expect(HoverZone.keepsRevealed(x: 1320, y: 940, boxes: b))          // the chevron itself
    }

    @Test func chevronAlwaysTriggersEvenWithIconsBetween() {
        #expect(HoverZone.keepsRevealed(x: 1320, y: 940, boxes: boxes(leftmost: 1100)))
    }

    @Test func belowTheBarNeverTriggers() {
        #expect(!HoverZone.keepsRevealed(x: 900, y: 800, boxes: boxes(leftmost: 1100)))
    }
}
