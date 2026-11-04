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
