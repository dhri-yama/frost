import Foundation

/// Where to drop Frost's chevron so hidden icons appear on its left: next to the system's own items at the right edge.
public enum ChevronPlacement {
    /// The x to release the ⌘-drag at: just inside the left edge of the "Control Center" item, or of the rightmost item
    /// if that one cannot be identified. Frost's own items are ignored. Nil if there is nothing to drop next to.
    public static func dropX(items: [MenuBarItem], ownPID: Int) -> Double? {
        let others = items.filter { $0.pid != ownPID }
        let controlCenter = others.filter {
            $0.ownerName == "Control Center" && ($0.title ?? "").localizedCaseInsensitiveContains("control center")
        }
        guard let target = controlCenter.max(by: { $0.minX < $1.minX }) ?? others.max(by: { $0.minX < $1.minX }) else { return nil }
        return target.minX + 1
    }
}
