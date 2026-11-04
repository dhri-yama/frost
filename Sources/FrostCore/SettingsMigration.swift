import Foundation

/// Carrying settings over when the bundle identifier changed (from the development placeholder `local.frost`).
public enum SettingsMigration {
    /// The identifier used before the first public release.
    public static let previousBundleID = "local.frost"

    /// Keys from the old settings domain worth copying: everything the new domain does not already have, except the window
    /// and status-item entries macOS writes for the old bundle (they describe the old app's window positions and menu bar slots).
    public static func keysToCopy(old: [String: Any], existing: Set<String>) -> [String] {
        old.keys.filter { !existing.contains($0) && !$0.hasPrefix("NS") }.sorted()
    }
}
