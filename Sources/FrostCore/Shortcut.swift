import Foundation

/// A global keyboard shortcut: a virtual key code and Carbon-style modifier flags (the values RegisterEventHotKey takes).
public struct Shortcut: Codable, Equatable {
    public var keyCode: Int
    public var modifiers: UInt32

    public static let command: UInt32 = 256, shift: UInt32 = 512, option: UInt32 = 2048, control: UInt32 = 4096

    public init(keyCode: Int, modifiers: UInt32) { self.keyCode = keyCode; self.modifiers = modifiers }

    /// Needs a known key and at least one of ⌃ ⌥ ⌘. Shift alone would make an ordinary typing key a global shortcut.
    public var isValid: Bool {
        Self.keyNames[keyCode] != nil && modifiers & (Self.command | Self.option | Self.control) != 0
    }

    /// For example "⌃⌥H": modifiers in the order macOS shows them, then the key.
    public var display: String {
        var s = ""
        if modifiers & Self.control != 0 { s += "⌃" }
        if modifiers & Self.option != 0 { s += "⌥" }
        if modifiers & Self.shift != 0 { s += "⇧" }
        if modifiers & Self.command != 0 { s += "⌘" }
        return s + (Self.keyNames[keyCode] ?? "?")
    }

    /// Virtual key codes (ANSI layout) and how to show them.
    static let keyNames: [Int: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
        16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
        30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 36: "Return", 37: "L", 38: "J", 39: "'", 40: "K", 41: ";", 42: "\\",
        43: ",", 44: "/", 45: "N", 46: "M", 47: ".", 48: "Tab", 49: "Space", 50: "`", 51: "Delete",
        96: "F5", 97: "F6", 98: "F7", 99: "F3", 100: "F8", 101: "F9", 103: "F11", 109: "F10", 111: "F12", 118: "F4", 120: "F2", 122: "F1",
        123: "←", 124: "→", 125: "↓", 126: "↑",
    ]
}

/// The things a global shortcut can do.
public enum ShortcutAction: String, CaseIterable, Codable {
    case toggle, search, presenting

    public var title: String {
        switch self {
        case .toggle: return "Show or hide items"
        case .search: return "Search menu bar items"
        case .presenting: return "Presenting mode"
        }
    }

    public var defaultShortcut: Shortcut {
        switch self {
        case .toggle: return Shortcut(keyCode: 4, modifiers: Shortcut.control | Shortcut.option)      // ⌃⌥H
        case .search: return Shortcut(keyCode: 49, modifiers: Shortcut.control | Shortcut.option)     // ⌃⌥Space
        case .presenting: return Shortcut(keyCode: 35, modifiers: Shortcut.control | Shortcut.option) // ⌃⌥P
        }
    }
}

/// One shortcut per action. Anything not set (or missing from saved data) uses the default.
public struct ShortcutSet: Codable, Equatable {
    private var custom: [ShortcutAction: Shortcut] = [:]

    public init() {}

    public subscript(_ action: ShortcutAction) -> Shortcut {
        get { custom[action] ?? action.defaultShortcut }
        set { custom[action] = newValue }
    }

    /// Another action that already uses `shortcut`, if any.
    public func conflict(for shortcut: Shortcut, action: ShortcutAction) -> ShortcutAction? {
        ShortcutAction.allCases.first { $0 != action && self[$0] == shortcut }
    }

    // Stored as { "toggle": {...}, ... } keyed by action name, so saved data stays readable and tolerates missing keys.
    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode([String: Shortcut].self)
        for a in ShortcutAction.allCases { if let s = raw[a.rawValue] { custom[a] = s } }
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(Dictionary(uniqueKeysWithValues: custom.map { ($0.key.rawValue, $0.value) }))
    }
}
