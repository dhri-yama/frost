import Foundation

/// A semantic version (MAJOR.MINOR.PATCH). Used for the About pane and the optional update check.
public struct SemVer: Comparable, CustomStringConvertible, Equatable {
    public let major: Int, minor: Int, patch: Int

    public init(_ major: Int, _ minor: Int, _ patch: Int) { self.major = major; self.minor = minor; self.patch = patch }

    /// Parses "1.2.3" (a leading "v" is allowed). Returns nil for anything else.
    public init?(_ string: String) {
        let s = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = (s.hasPrefix("v") ? String(s.dropFirst()) : s).split(separator: ".", omittingEmptySubsequences: false)
        guard parts.count == 3, let a = Int(parts[0]), let b = Int(parts[1]), let c = Int(parts[2]), a >= 0, b >= 0, c >= 0 else { return nil }
        self.init(a, b, c)
    }

    public var description: String { "\(major).\(minor).\(patch)" }

    public static func < (l: SemVer, r: SemVer) -> Bool {
        (l.major, l.minor, l.patch) < (r.major, r.minor, r.patch)
    }
}
