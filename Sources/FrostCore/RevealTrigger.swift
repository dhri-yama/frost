import Foundation

/// What makes hidden icons appear: a click on Frost's chevron, the pointer resting on it, or either.
public enum RevealTrigger: Int, CaseIterable, Codable {
    case click = 0, hover = 1, both = 2

    public var onClick: Bool { self != .hover }
    public var onHover: Bool { self != .click }

    public var label: String {
        switch self {
        case .click: return "On click"
        case .hover: return "On hover"
        case .both: return "On click or hover"
        }
    }
}

/// A rectangle in screen coordinates (any origin, as long as all boxes and the point share it).
public struct HoverBox: Equatable {
    public var minX: Double, minY: Double, maxX: Double, maxY: Double
    public init(minX: Double, minY: Double, maxX: Double, maxY: Double) { self.minX = minX; self.minY = minY; self.maxX = maxX; self.maxY = maxY }
}

public enum HoverZone {
    /// How far outside a box the pointer may stray and still count as inside.
    public static let slack = 6.0

    /// Where hovering reveals the hidden icons: the chevron itself, and the empty stretch of menu bar between the app menus
    /// and the leftmost visible icon (the screen's middle stands in for the end of the app menus). Without icon positions
    /// the empty stretch ends at the chevron.
    public static func triggerBoxes(screenMinX: Double, screenMaxX: Double, barMinY: Double, barMaxY: Double,
                                    chevronMinX: Double, chevronMaxX: Double, leftmostVisibleMinX: Double?) -> [HoverBox] {
        let start = (screenMinX + screenMaxX) / 2
        let end = min(leftmostVisibleMinX ?? chevronMinX, chevronMinX)
        var boxes = [HoverBox(minX: chevronMinX, minY: barMinY, maxX: chevronMaxX, maxY: barMaxY)]
        if end > start { boxes.append(HoverBox(minX: start, minY: barMinY, maxX: end, maxY: barMaxY)) }
        return boxes
    }

    /// True while the pointer is in the menu bar strip or on the revealed panel. Icons revealed by hovering stay until it leaves.
    public static func keepsRevealed(x: Double, y: Double, boxes: [HoverBox]) -> Bool {
        boxes.contains { x >= $0.minX - slack && x <= $0.maxX + slack && y >= $0.minY - slack && y <= $0.maxY + slack }
    }
}
