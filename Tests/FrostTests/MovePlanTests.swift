import Testing
@testable import FrostCore

@Suite struct MovePlanTests {
    private let item = MenuBarItem(windowID: 1, pid: 5, ownerName: "Dropbox", minX: 900, width: 24)

    @Test func hidingDropsJustInsideTheDividersLeftEdge() {
        let p = MovePlan.make(item: item, toHidden: true, dividerMinX: 1200, toggleMinX: 1230, barY: 12)
        #expect(p.start == MovePoint(x: 912, y: 12))        // centre of the item
        #expect(p.end == MovePoint(x: 1201, y: 12))
    }

    @Test func showingDropsJustInsideTheTogglesLeftEdge() {
        let p = MovePlan.make(item: item, toHidden: false, dividerMinX: 1200, toggleMinX: 1230, barY: 12)
        #expect(p.end == MovePoint(x: 1231, y: 12))
    }

    @Test func dragIsInterpolatedWithAtLeastTwoSteps() {
        let p = MovePlan.make(item: item, toHidden: true, dividerMinX: 1200, toggleMinX: 1230, barY: 12)
        let path = p.path(steps: 4)
        #expect(path.count == 5)
        #expect(path.first == p.start && path.last == p.end)
        #expect(MovePlan.make(item: item, toHidden: true, dividerMinX: 1200, toggleMinX: 1230, barY: 12).path(steps: 0).count == 3)
    }

    @Test func alreadyOnTheRightSideNeedsNoMove() {
        #expect(!MovePlan.needsMove(item: item, toHidden: true, dividerMinX: 1200))      // left of divider already
        #expect(MovePlan.needsMove(item: item, toHidden: false, dividerMinX: 1200))
        #expect(MovePlan.needsMove(item: MenuBarItem(windowID: 2, pid: 6, ownerName: "X", minX: 1400, width: 24), toHidden: true, dividerMinX: 1200))
    }
}
