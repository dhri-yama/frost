import Foundation

public struct MovePoint: Equatable {
    public var x: Double, y: Double
    public init(x: Double, y: Double) { self.x = x; self.y = y }
}

/// Where to press and release the mouse to ⌘-drag a menu bar item to the other side of Frost's divider.
/// Coordinates are global screen points with the origin at the top left, as Accessibility and CGEvent use.
public struct MovePlan: Equatable {
    public let start: MovePoint
    public let end: MovePoint

    /// Hiding releases just inside the divider's left edge (the item lands left of it); showing releases just inside the
    /// toggle's left edge (the item lands between the divider and the toggle, so it stays visible).
    public static func make(item: MenuBarItem, toHidden: Bool, dividerMinX: Double, toggleMinX: Double, barY: Double) -> MovePlan {
        MovePlan(start: MovePoint(x: item.minX + item.width / 2, y: barY),
                 end: MovePoint(x: (toHidden ? dividerMinX : toggleMinX) + 1, y: barY))
    }

    /// False if the item is already on the requested side of the divider.
    public static func needsMove(item: MenuBarItem, toHidden: Bool, dividerMinX: Double) -> Bool {
        (item.minX < dividerMinX) != toHidden
    }

    /// Points along the drag, evenly spaced, including both ends. At least two steps.
    public func path(steps: Int) -> [MovePoint] {
        let n = max(steps, 2)
        return (0...n).map { i in
            let t = Double(i) / Double(n)
            return MovePoint(x: start.x + (end.x - start.x) * t, y: start.y + (end.y - start.y) * t)
        }
    }
}
