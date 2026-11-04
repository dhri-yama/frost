import Foundation

/// Type-to-filter over menu bar items, used by the search panel.
public enum ItemSearch {
    /// Items whose name or title contains `query` (case-insensitive, ignoring surrounding spaces). Ranked: name starts with
    /// the query, then name contains it, then only the title contains it. Ties keep the original (left-to-right) order.
    public static func filter(_ items: [MenuBarItem], query: String) -> [MenuBarItem] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return items }
        func rank(_ i: MenuBarItem) -> Int? {
            let name = i.ownerName.lowercased()
            if name.hasPrefix(q) { return 0 }
            if name.contains(q) { return 1 }
            if i.title?.lowercased().contains(q) == true { return 2 }
            return nil
        }
        return items.enumerated()
            .compactMap { o in rank(o.element).map { (o.offset, $0, o.element) } }
            .sorted { ($0.1, $0.0) < ($1.1, $1.0) }
            .map { $0.2 }
    }

    /// Moves a selection up or down a list, wrapping at both ends. An empty list stays at 0.
    public static func move(selected: Int, count: Int, by delta: Int) -> Int {
        guard count > 0 else { return 0 }
        return ((selected + delta) % count + count) % count
    }
}
