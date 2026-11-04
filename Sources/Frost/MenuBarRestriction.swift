import AppKit
import FrostCore

enum RestrictionError: LocalizedError {
    case frameworkNotLoaded(String), classesNotFound
    var errorDescription: String? {
        switch self {
        case .frameworkNotLoaded(let why): return "The system menu bar framework did not load: \(why)"
        case .classesNotFound: return "This version of macOS does not have the menu bar allow-list Frost uses."
        }
    }
}

/// Hides apps' menu bar items through the system allow-list: MenuBarAgent keeps only the apps on the list visible.
/// This uses the private `MenuBarClientCore` framework, loaded at run time, so it can disappear in any macOS update.
/// Frost checks for the classes at launch and falls back to the divider if they are missing.
///
/// Facts this relies on (found by the Ellipsis project; see CREDITS.md): the list holds bundle identifiers of apps that stay
/// visible; the restriction ends when the process exits; and the app must be inside /Applications for its own icon to match.
final class MenuBarRestriction {
    private static let path = "/System/Library/PrivateFrameworks/MenuBarClientCore.framework/MenuBarClientCore"
    /// System items are given as integer codes (0–6 are the public AEMenuBarItem constants, 8 is Control Center). A generous
    /// range keeps every system item visible; unknown codes are ignored.
    private static let systemItems = (0...40).map { NSNumber(value: $0) }

    private let configurationClass: NSObject.Type
    private let assertionClass: NSObject.Type
    private var assertion: NSObject?
    private var list = AllowList()
    private(set) var failure: String?
    /// Called (on the main queue) when an allow-list is activated: nil on success, or the system's error message.
    var onFailure: ((String?) -> Void)?

    var isActive: Bool { assertion != nil }

    /// True if the private classes can be loaded on this system.
    static func probe() -> Bool { (try? MenuBarRestriction()) != nil }

    init() throws {
        guard dlopen(Self.path, RTLD_NOW) != nil else { throw RestrictionError.frameworkNotLoaded(String(cString: dlerror())) }
        guard let c = NSClassFromString("MBAssessmentModeConfiguration") as? NSObject.Type,
              let a = NSClassFromString("MBAssessmentModeAssertion") as? NSObject.Type else { throw RestrictionError.classesNotFound }
        configurationClass = c; assertionClass = a
    }

    /// Hides the given apps and keeps every other running app and all system items visible. The list is a snapshot of the
    /// running apps, so call it again when an app launches. Does nothing if it would change nothing.
    func apply(hidden: Set<String>) {
        let running = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        let allowed = running.subtracting(hidden)
        guard list.needsApply(hidden: hidden, allowed: allowed) else { return }
        list.record(hidden: hidden, allowed: allowed)

        let configuration = (configurationClass as AnyObject)
            .perform(NSSelectorFromString("alloc"))?.takeUnretainedValue()
            .perform(NSSelectorFromString("initWithAllowedSystemItems:allowedBundleIdentifiers:"),
                     with: Self.systemItems as NSArray, with: allowed.sorted() as NSArray)?
            .takeUnretainedValue()
        let new = assertionClass.init()
        let previous = assertion
        // The newest assertion wins while several are alive, so keep the old one until the new one has reported back;
        // dropping it sooner would lift every restriction for a moment and make all icons flash.
        let done: @convention(block) (Any?) -> Void = { [weak self] error in
            _ = previous?.perform(NSSelectorFromString("invalidate"))
            DispatchQueue.main.async {
                guard let self, self.assertion === new else { return }
                if let error { self.failure = String(describing: error); self.list.clear() } else { self.failure = nil }
                self.onFailure?(self.failure)
            }
        }
        _ = new.perform(NSSelectorFromString("activateWithConfiguration:completionHandler:"), with: configuration, with: done)
        assertion = new
    }

    /// Lifts the restriction: every icon comes back.
    func release() {
        _ = assertion?.perform(NSSelectorFromString("invalidate"))
        assertion = nil
        list.clear()
    }
}
