import AppKit
import ApplicationServices
import FrostCore

/// Finds menu bar items through the Accessibility API: every app that owns status items exposes them as the
/// children of its `AXExtrasMenuBar`. Needs the Accessibility permission.
enum AccessibilityScan {
    static var trusted: Bool { AXIsProcessTrusted() }

    /// Elements from the latest scan, keyed by item id, so the panel can click an item later.
    private static var elements: [Int: AXUIElement] = [:]
    private static let lock = NSLock()

    /// Clicks an item found by the latest scan (AXPress). Returns false if the item is gone or the app refused.
    @discardableResult static func press(id: Int) -> Bool {
        lock.lock(); let el = elements[id]; lock.unlock()
        guard let el else { return false }
        return AXUIElementPerformAction(el, kAXPressAction as CFString) == .success
    }

    /// Shows the system's Accessibility prompt (once; afterwards it only opens nothing, so also offer `openSettings`).
    static func requestTrust() {
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary)
    }

    static func openSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") { NSWorkspace.shared.open(url) }
    }

    /// Items sorted left to right. Empty when the permission is missing. Ids are `pid * 1000 + index`, unique per scan.
    static func scan() -> [MenuBarItem] {
        guard trusted else { return [] }
        var out: [MenuBarItem] = []
        var found: [Int: AXUIElement] = [:]
        for app in NSWorkspace.shared.runningApplications where app.activationPolicy != .prohibited {
            let root = AXUIElementCreateApplication(app.processIdentifier)
            AXUIElementSetMessagingTimeout(root, 0.25)   // a hung app must not stall the whole scan
            var bar: CFTypeRef?
            guard AXUIElementCopyAttributeValue(root, "AXExtrasMenuBar" as CFString, &bar) == .success, let bar else { continue }
            var kids: CFTypeRef?
            AXUIElementCopyAttributeValue(bar as! AXUIElement, kAXChildrenAttribute as CFString, &kids)
            for (i, child) in (kids as? [AXUIElement] ?? []).enumerated() {
                guard let p = point(child, kAXPositionAttribute), let s = size(child) else { continue }
                let title = string(child, kAXTitleAttribute) ?? string(child, kAXDescriptionAttribute)
                found[Int(app.processIdentifier) * 1000 + i] = child
                out.append(MenuBarItem(windowID: Int(app.processIdentifier) * 1000 + i, pid: Int(app.processIdentifier),
                                       ownerName: app.localizedName ?? "Unknown", minX: Double(p.x), width: Double(s.width), title: title))
            }
        }
        lock.lock(); elements = found; lock.unlock()
        return out.sorted { $0.minX < $1.minX }
    }

    private static func point(_ e: AXUIElement, _ attr: String) -> CGPoint? {
        var v: CFTypeRef?
        guard AXUIElementCopyAttributeValue(e, attr as CFString, &v) == .success, let v, CFGetTypeID(v) == AXValueGetTypeID() else { return nil }
        var p = CGPoint.zero
        return AXValueGetValue(v as! AXValue, .cgPoint, &p) ? p : nil
    }

    private static func size(_ e: AXUIElement) -> CGSize? {
        var v: CFTypeRef?
        guard AXUIElementCopyAttributeValue(e, kAXSizeAttribute as CFString, &v) == .success, let v, CFGetTypeID(v) == AXValueGetTypeID() else { return nil }
        var s = CGSize.zero
        return AXValueGetValue(v as! AXValue, .cgSize, &s) ? s : nil
    }

    private static func string(_ e: AXUIElement, _ attr: String) -> String? {
        var v: CFTypeRef?
        guard AXUIElementCopyAttributeValue(e, attr as CFString, &v) == .success, let s = v as? String, !s.isEmpty else { return nil }
        return s
    }
}
