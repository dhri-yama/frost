import Foundation

/// The hide/show state of the menu bar. Items to the left of Frost's divider are hidden while `collapsed`.
/// The divider hides them by growing very wide, which pushes them off the screen edge; this type only holds the logic.
public struct DividerState: Equatable {
    /// Width of the divider while hiding. Wider than any display.
    public static let collapsedLength: Double = 10_000
    /// Width of the divider while showing: just enough for a thin separator glyph.
    public static let expandedLength: Double = 18

    public private(set) var collapsed: Bool

    public init(collapsed: Bool = true) { self.collapsed = collapsed }

    public var length: Double { collapsed ? Self.collapsedLength : Self.expandedLength }

    public mutating func toggle() { collapsed.toggle() }
    public mutating func collapse() { collapsed = true }
    public mutating func expand() { collapsed = false }
}

/// How long revealed items stay visible before hiding again. `nil` seconds means never auto-hide.
public enum AutoHide: Int, CaseIterable, Codable {
    case never = 0, fiveSeconds = 5, tenSeconds = 10, thirtySeconds = 30

    public var seconds: TimeInterval? { self == .never ? nil : TimeInterval(rawValue) }

    public var label: String {
        switch self {
        case .never: return "Never"
        case .fiveSeconds: return "After 5 seconds"
        case .tenSeconds: return "After 10 seconds"
        case .thirtySeconds: return "After 30 seconds"
        }
    }
}
