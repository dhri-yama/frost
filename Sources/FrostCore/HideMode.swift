import Foundation

/// How Frost decides which apps to hide (macOS 27 allow-list).
public enum HideMode: Int, CaseIterable, Codable {
    /// Hide the apps on the list; everything else shows.
    case chosen = 0
    /// Show only the apps on the list; every other app is hidden, including ones that launch later.
    case allExcept = 1

    public var label: String { self == .chosen ? "Apps I choose" : "Everything except apps I choose" }
}

public enum HiddenResolver {
    /// The bundle identifiers to hide right now.
    /// - `chosen`: the hide list in `.chosen` mode, or the keep-visible list in `.allExcept` mode.
    /// - `running`: bundle identifiers of running apps (only needed for `.allExcept`).
    /// - `neverHide`: apps that must always show, such as Frost itself.
    /// In `.allExcept` mode Apple's own apps (`com.apple.`) are left alone: their menu bar items are system items, which the
    /// system keeps visible anyway.
    public static func hidden(mode: HideMode, chosen: Set<String>, running: Set<String>, neverHide: Set<String>) -> Set<String> {
        switch mode {
        case .chosen:
            return chosen.subtracting(neverHide)
        case .allExcept:
            return running.filter { !chosen.contains($0) && !neverHide.contains($0) && !$0.hasPrefix("com.apple.") }.reduce(into: Set<String>()) { $0.insert($1) }
        }
    }
}
