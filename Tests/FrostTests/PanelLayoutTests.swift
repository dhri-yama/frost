import Testing
@testable import FrostCore

@Suite struct PanelLayoutTests {
    @Test func sizeGrowsWithItemsAndWrapsAtMaxColumns() {
        let one = PanelLayout.size(itemCount: 1)
        let eight = PanelLayout.size(itemCount: 8)
        let nine = PanelLayout.size(itemCount: 9)
        #expect(one.width < eight.width)
        #expect(nine.width == eight.width)       // wraps instead of growing wider
        #expect(nine.height > eight.height)
    }

    @Test func emptyPanelHasRoomForMessage() {
        let e = PanelLayout.size(itemCount: 0)
        #expect(e.width >= 200 && e.height >= 56)
    }

    @Test func rightAlignsToAnchorWhenItFits() {
        #expect(PanelLayout.originX(anchorMaxX: 1000, width: 300, screenMinX: 0, screenMaxX: 1470) == 700)
    }

    @Test func clampsInsideTheScreen() {
        #expect(PanelLayout.originX(anchorMaxX: 100, width: 300, screenMinX: 0, screenMaxX: 1470) == PanelLayout.margin)
        #expect(PanelLayout.originX(anchorMaxX: 2000, width: 300, screenMinX: 0, screenMaxX: 1470) == 1470 - 300 - PanelLayout.margin)
    }

    @Test func revealModeRoundTrips() {
        #expect(RevealMode(rawValue: RevealMode.panel.rawValue) == .panel)
        #expect(RevealMode.allCases.count == 2)
    }
}
