/// What the newest system allow-list hides and allows, so applying one that would change nothing is skipped. Every new
/// allow-list makes the system lay the menu bar out again; a helper app that starts and quits every second would
/// otherwise keep it busy for good and icon clicks would get lost.
public struct AllowList {
    private var hidden: Set<String>?
    private var allowed: Set<String> = []

    public init() {}

    /// True if applying `hidden` and `allowed` would show or hide something the newest one does not. An allowed app that
    /// has quit may stay in the list: it does no harm, and its next launch then needs no new allow-list.
    public func needsApply(hidden: Set<String>, allowed: Set<String>) -> Bool {
        hidden != self.hidden || !allowed.isSubset(of: self.allowed)
    }

    public mutating func record(hidden: Set<String>, allowed: Set<String>) {
        self.hidden = hidden
        self.allowed = allowed
    }

    public mutating func clear() {
        hidden = nil
        allowed = []
    }
}
