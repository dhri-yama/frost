import Foundation

/// One status item in the menu bar, as reported by the window server.
public struct MenuBarItem: Equatable, Identifiable {
    public let windowID: Int
    public let pid: Int
    public let ownerName: String
    public let minX: Double, width: Double

    public var id: Int { windowID }
    public var maxX: Double { minX + width }

    public init(windowID: Int, pid: Int, ownerName: String, minX: Double, width: Double) {
        self.windowID = windowID; self.pid = pid; self.ownerName = ownerName; self.minX = minX; self.width = width
    }
}

/// Reads the window server's window list (CGWindowListCopyWindowInfo) to find menu bar items.
/// Needs no permission: owner names are available without Screen Recording. Window titles are not read.
public enum MenuBarScan {
    /// Window level of status items (kCGStatusWindowLevel).
    static let statusLevel = 25
    /// Menu bar items are never taller than this; filters out full-screen windows that share the level.
    static let maxHeight = 40.0

    /// Status item windows from a raw window list, sorted left to right. Malformed entries are skipped.
    public static func parse(_ windows: [[String: Any]]) -> [MenuBarItem] {
        windows.compactMap { w -> MenuBarItem? in
            guard num(w["kCGWindowLayer"]) == Double(statusLevel),
                  let id = num(w["kCGWindowNumber"]), let pid = num(w["kCGWindowOwnerPID"]),
                  let b = w["kCGWindowBounds"] as? [String: Any],
                  let x = num(b["X"]), let width = num(b["Width"]), let h = num(b["Height"]), h <= maxHeight, width > 0
            else { return nil }
            return MenuBarItem(windowID: Int(id), pid: Int(pid), ownerName: (w["kCGWindowOwnerName"] as? String) ?? "Unknown",
                               minX: x, width: width)
        }
        .sorted { $0.minX < $1.minX }
    }

    /// Splits items into those left of Frost's divider (hidden when collapsed) and the rest. Frost's own items are left out.
    /// If the divider is not in the list, nothing is considered hidden.
    public static func group(_ items: [MenuBarItem], dividerWindowID: Int, ownWindowIDs: Set<Int>) -> (visible: [MenuBarItem], hidden: [MenuBarItem]) {
        let others = items.filter { !ownWindowIDs.contains($0.windowID) }
        guard let divider = items.first(where: { $0.windowID == dividerWindowID }) else { return (others, []) }
        return (others.filter { $0.minX >= divider.minX }, others.filter { $0.minX < divider.minX })
    }

    private static func num(_ any: Any?) -> Double? { (any as? NSNumber)?.doubleValue }
}
