import Foundation

/// Frost has two themes, Day and Night. Earlier versions had four; this maps whatever was saved to one that exists.
public enum ThemeName {
    public static let day = "Day"
    public static let night = "Night"

    /// "Paper" (the old light theme) becomes Day. Every other old or unknown name, and nothing saved at all, becomes Night.
    public static func resolve(_ saved: String?) -> String {
        switch saved {
        case "Day", "Paper": return day
        default: return night
        }
    }
}

/// The icon Frost shows in the menu bar. Each has one symbol while hiding and one while showing.
public enum MenuBarIcon: Int, CaseIterable, Codable {
    case chevron = 0, dots, glass, mug, snowflake, eye

    public var label: String {
        switch self {
        case .chevron: return "Chevron"
        case .dots: return "Dots"
        case .glass: return "Glass"
        case .mug: return "Mug"
        case .snowflake: return "Snowflake"
        case .eye: return "Eye"
        }
    }

    /// An SF Symbol name. `collapsed` is true while icons are hidden.
    public func symbol(collapsed: Bool) -> String {
        switch self {
        case .chevron: return collapsed ? "chevron.left" : "chevron.right"
        case .dots: return collapsed ? "ellipsis.circle" : "ellipsis.circle.fill"
        case .glass: return collapsed ? "wineglass" : "wineglass.fill"
        case .mug: return collapsed ? "cup.and.saucer" : "cup.and.saucer.fill"
        case .snowflake: return collapsed ? "snowflake" : "snowflake.circle.fill"
        case .eye: return collapsed ? "eye.slash" : "eye"
        }
    }

    /// The saved icon, or the chevron if nothing valid was saved.
    public static func resolve(rawValue: Int?) -> MenuBarIcon {
        rawValue.flatMap(MenuBarIcon.init(rawValue:)) ?? .chevron
    }
}
