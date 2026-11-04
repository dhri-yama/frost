import AppKit
import FrostCore

/// Owns Frost's two menu bar items. The divider sits left of the toggle; while collapsed it is 10,000pt wide,
/// which pushes every item to its left off the edge of the screen. Clicking the toggle collapses or expands it.
final class MenuBarController: NSObject {
    private let toggleItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)  // created first = rightmost
    private let dividerItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var state = DividerState()
    private var hideTimer: Timer?
    private let store: SettingsStore
    var openSettings: () -> Void = {}
    var dividerWindowID: Int { dividerItem.button?.window?.windowNumber ?? -1 }
    var ownWindowIDs: Set<Int> { Set([dividerItem, toggleItem].compactMap { $0.button?.window?.windowNumber }) }

    init(store: SettingsStore) {
        self.store = store
        super.init()
        toggleItem.autosaveName = "frost.toggle"
        dividerItem.autosaveName = "frost.divider"
        toggleItem.button?.target = self
        toggleItem.button?.action = #selector(clicked(_:))
        toggleItem.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
        toggleItem.button?.setAccessibilityLabel("Frost: show or hide menu bar items")
        store.onAutoHideChange = { [weak self] in self?.scheduleAutoHide() }
        if !store.hideOnLaunch { state.expand() }
        apply()
    }

    @objc private func clicked(_ sender: NSStatusBarButton) {
        let e = NSApp.currentEvent
        if e?.type == .rightMouseUp || e?.modifierFlags.contains(.control) == true { showMenu(); return }
        state.toggle()
        apply()
    }

    private func apply() {
        dividerItem.length = state.length
        if let b = dividerItem.button {
            // While collapsed the divider is off-screen wide; draw nothing. While expanded it is a thin separator.
            b.image = state.collapsed ? nil : NSImage(systemSymbolName: "line.diagonal", accessibilityDescription: "Frost divider")
            b.alphaValue = 0.5
        }
        let name = state.collapsed ? "chevron.left" : "chevron.right"
        toggleItem.button?.image = NSImage(systemSymbolName: name, accessibilityDescription: state.collapsed ? "Show hidden items" : "Hide items")
        scheduleAutoHide()
    }

    private func scheduleAutoHide() {
        hideTimer?.invalidate()
        guard !state.collapsed, let s = store.autoHide.seconds else { return }
        hideTimer = Timer.scheduledTimer(withTimeInterval: s, repeats: false) { [weak self] _ in
            self?.state.collapse()
            self?.apply()
        }
    }

    private func showMenu() {
        let menu = NSMenu()
        menu.addItem(withTitle: state.collapsed ? "Show hidden items" : "Hide items", action: #selector(toggleFromMenu), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Settings…", action: #selector(settingsFromMenu), keyEquivalent: ",").target = self
        menu.addItem(withTitle: "Quit Frost", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        toggleItem.menu = menu
        toggleItem.button?.performClick(nil)
        toggleItem.menu = nil   // restore plain click behaviour
    }

    @objc private func toggleFromMenu() { state.toggle(); apply() }
    @objc private func settingsFromMenu() { openSettings() }
}
