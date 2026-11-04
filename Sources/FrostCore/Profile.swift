import Foundation

/// A saved layout: which apps' items are hidden. Items are matched by app name, so a profile survives relaunches.
public struct Profile: Codable, Equatable, Identifiable {
    public let id: String
    public var name: String
    public var hiddenOwners: [String]
    /// Bundle identifiers of the hidden apps. macOS 27 hides by these; older profiles have none.
    public var hiddenBundleIDs: [String]

    public init(id: String = UUID().uuidString, name: String, hiddenOwners: [String], hiddenBundleIDs: [String] = []) {
        self.id = id; self.name = name; self.hiddenOwners = hiddenOwners; self.hiddenBundleIDs = hiddenBundleIDs
    }

    // Profiles saved before 0.10.0 have no `hiddenBundleIDs`, so decode it as optional.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        hiddenOwners = try c.decode([String].self, forKey: .hiddenOwners)
        hiddenBundleIDs = try c.decodeIfPresent([String].self, forKey: .hiddenBundleIDs) ?? []
    }

    /// Records the apps whose items are currently hidden.
    public static func capturing(name: String, hidden: [MenuBarItem]) -> Profile {
        Profile(name: name, hiddenOwners: Array(Set(hidden.map(\.ownerName))).sorted(),
                hiddenBundleIDs: Array(Set(hidden.compactMap(\.bundleID))).sorted())
    }
}

public struct ProfileMove: Equatable {
    public let id: Int
    public let toHidden: Bool
    public init(id: Int, toHidden: Bool) { self.id = id; self.toHidden = toHidden }
}

public enum ProfilePlan {
    /// The moves needed to make `items` match the profile: items of apps in `hiddenOwners` go left of the divider,
    /// all others go right. Items already on the right side are skipped.
    public static func moves(items: [MenuBarItem], profile: Profile, dividerMinX: Double) -> [ProfileMove] {
        let hidden = Set(profile.hiddenOwners)
        return items.compactMap { i in
            let want = hidden.contains(i.ownerName)
            return MovePlan.needsMove(item: i, toHidden: want, dividerMinX: dividerMinX) ? ProfileMove(id: i.id, toHidden: want) : nil
        }
    }
}
