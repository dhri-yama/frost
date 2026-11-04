import Foundation

/// Where hidden items appear when revealed: in the menu bar itself, or in a panel under it.
public enum RevealMode: Int, CaseIterable, Codable {
    case inline = 0, panel = 1

    public var label: String { self == .inline ? "In the menu bar" : "In a panel below it" }
}

/// Geometry of the second-bar panel. Pure maths so it can be tested without a screen.
public enum PanelLayout {
    public static let tile = 36.0, gap = 8.0, padding = 14.0, maxColumns = 8, margin = 8.0

    /// Panel size for a number of item tiles. Wraps to more rows at `maxColumns`; never smaller than room for a message.
    public static func size(itemCount: Int) -> (width: Double, height: Double) {
        guard itemCount > 0 else { return (220, 56) }
        let cols = min(itemCount, maxColumns), rows = (itemCount + maxColumns - 1) / maxColumns
        return (padding * 2 + Double(cols) * tile + Double(cols - 1) * gap,
                padding * 2 + Double(rows) * tile + Double(rows - 1) * gap)
    }

    /// Left edge for the panel: right-aligned to the toggle, kept `margin` inside the screen.
    public static func originX(anchorMaxX: Double, width: Double, screenMinX: Double, screenMaxX: Double) -> Double {
        min(max(anchorMaxX - width, screenMinX + margin), screenMaxX - width - margin)
    }
}
