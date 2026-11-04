import Foundation

/// One status item in the menu bar, as reported by the window server.
public struct MenuBarItem: Equatable, Identifiable {
    public let windowID: Int
    public let pid: Int
    public let ownerName: String
    public let minX: Double, width: Double
    /// Accessibility title or description, when the Accessibility scan supplied one.
    public let title: String?
    /// The owning app's bundle identifier, when known. macOS 27 hides menu bar items per app, by this identifier.
    public let bundleID: String?

    public var id: Int { windowID }
    /// Apple's own items (Control Center, Clock, Wi-Fi...). macOS 27 always keeps these visible, so hiding them is not possible.
    public var isSystemItem: Bool { bundleID?.hasPrefix("com.apple.") == true }
    public var maxX: Double { minX + width }

    public init(windowID: Int, pid: Int, ownerName: String, minX: Double, width: Double, title: String? = nil, bundleID: String? = nil) {
        self.windowID = windowID; self.pid = pid; self.ownerName = ownerName; self.minX = minX; self.width = width; self.title = title; self.bundleID = bundleID
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

    /// Splits items by horizontal position: left of `dividerMinX` is hidden when Frost is collapsed. Items owned by `ownPID`
    /// (Frost's toggle and divider) are left out. With no divider position, nothing is considered hidden.
    public static func group(_ items: [MenuBarItem], dividerMinX: Double?, ownPID: Int) -> (visible: [MenuBarItem], hidden: [MenuBarItem]) {
        let others = items.filter { $0.pid != ownPID }
        guard let x = dividerMinX else { return (others, []) }
        return (others.filter { $0.minX >= x }, others.filter { $0.minX < x })
    }

    /// Splits items by app: those whose bundle identifier is in `hiddenBundleIDs` are hidden. Items owned by `ownPID`
    /// (Frost's own) are left out. Used on macOS 27, where hiding is per app and has no position.
    public static func group(_ items: [MenuBarItem], hiddenBundleIDs: Set<String>, ownPID: Int) -> (visible: [MenuBarItem], hidden: [MenuBarItem]) {
        let others = items.filter { $0.pid != ownPID }
        let isHidden: (MenuBarItem) -> Bool = { $0.bundleID.map(hiddenBundleIDs.contains) ?? false }
        return (others.filter { !isHidden($0) }, others.filter(isHidden))
    }

    private static func num(_ any: Any?) -> Double? { (any as? NSNumber)?.doubleValue }
}
