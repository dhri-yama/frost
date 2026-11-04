import AppKit
import Combine
import SwiftUI
import FrostCore

/// Owns Frost's two menu bar items. The divider sits left of the toggle; while collapsed it is 10,000pt wide,
/// which pushes every item to its left off the edge of the screen. Clicking the toggle collapses or expands it.
final class MenuBarController: NSObject {
    private let toggleItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)  // created first = rightmost
    private let dividerItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var state = DividerState()
    private var hideTimer: Timer?
    private let store: SettingsStore
    private let items: ItemsModel
    private var panel: PanelWindow?
    private var clickMonitor: Any?
    private var itemsObservation: AnyCancellable?
    var openSettings: () -> Void = {}
    var openSearch: () -> Void = {}
    var dividerWindowID: Int { dividerItem.button?.window?.windowNumber ?? -1 }
    private var wasCollapsed = true

    /// Left edge of the toggle in screen coordinates.
    var toggleMinX: Double? { toggleItem.button?.window.map { Double($0.frame.minX) } }
    /// Vertical centre of the menu bar, in the top-left-origin coordinates that Accessibility and CGEvent use.
    var barY: Double? {
        guard let w = toggleItem.button?.window, let primary = NSScreen.screens.first else { return nil }
        return Double(primary.frame.height - w.frame.midY)
    }

    /// Expands the bar so every item has an on-screen position to drag from. Call `finishMove` afterwards.
    func prepareForMove() {
        wasCollapsed = state.collapsed
        closePanel()
        state.expand(); apply()
        hideTimer?.invalidate()
    }

    func finishMove() {
        if wasCollapsed { state.collapse() }
        apply()
    }

    var dividerMinX: Double? { dividerItem.button?.window.map { Double($0.frame.minX) } }
    var ownWindowIDs: Set<Int> { Set([dividerItem, toggleItem].compactMap { $0.button?.window?.windowNumber }) }

    init(store: SettingsStore, items: ItemsModel) {
        self.store = store
        self.items = items
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
        if store.revealMode == .panel { togglePanel(); return }
        state.toggle()
        apply()
    }

    // MARK: Panel

    private func togglePanel() {
        if panel?.isVisible == true { closePanel(); return }
        state.collapse(); apply()          // in panel mode the bar itself stays collapsed
        items.refresh()
        let view = PanelView(items: items) { [weak self] row in
            self?.closePanel()
            // Let the panel go first so the item's own menu opens in front.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { AccessibilityScan.press(id: row.id) }
        }
        let host = NSHostingView(rootView: view)
        let w = panel ?? PanelWindow(content: host)
        w.contentView = host
        w.appearance = Theme.appearance
        panel = w
        position(w)
        w.orderFrontRegardless()
        w.makeKey()
        clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in self?.closePanel() }
    }

    private func closePanel() {
        panel?.orderOut(nil)
        if let m = clickMonitor { NSEvent.removeMonitor(m); clickMonitor = nil }
    }

    /// Sits just under the menu bar, right-aligned to the toggle, kept on the toggle's screen. The panel is below the
    /// menu bar (visibleFrame excludes it), so the notch never covers it. It resizes itself as the scan fills in.
    private func position(_ w: NSWindow) {
        guard let button = toggleItem.button, let bw = button.window else { return }
        let screen = bw.screen ?? NSScreen.main ?? NSScreen.screens[0]
        let vis = screen.visibleFrame
        let size = PanelLayout.size(itemCount: items.hidden.count)
        let x = PanelLayout.originX(anchorMaxX: Double(bw.frame.maxX), width: size.width, screenMinX: Double(vis.minX), screenMaxX: Double(vis.maxX))
        w.setFrame(NSRect(x: x, y: vis.maxY - size.height - 6, width: size.width, height: size.height), display: true)
        itemsObservation = items.$hidden.sink { [weak self, weak w] _ in
            DispatchQueue.main.async { if let w { self?.position(w, resizeOnly: true) } }
        }
    }

    private func position(_ w: NSWindow, resizeOnly: Bool) {
        guard w.isVisible, let bw = toggleItem.button?.window else { return }
        let vis = (bw.screen ?? NSScreen.main ?? NSScreen.screens[0]).visibleFrame
        let size = PanelLayout.size(itemCount: items.hidden.count)
        let x = PanelLayout.originX(anchorMaxX: Double(bw.frame.maxX), width: size.width, screenMinX: Double(vis.minX), screenMaxX: Double(vis.maxX))
        w.setFrame(NSRect(x: x, y: vis.maxY - size.height - 6, width: size.width, height: size.height), display: true)
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
        menu.addItem(withTitle: store.revealMode == .panel ? "Show hidden items panel" : (state.collapsed ? "Show hidden items" : "Hide items"), action: #selector(toggleFromMenu), keyEquivalent: "").target = self
        menu.addItem(withTitle: "Search items…", action: #selector(searchFromMenu), keyEquivalent: "").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Settings…", action: #selector(settingsFromMenu), keyEquivalent: ",").target = self
        menu.addItem(withTitle: "Quit Frost", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        toggleItem.menu = menu
        toggleItem.button?.performClick(nil)
        toggleItem.menu = nil   // restore plain click behaviour
    }

    /// Same as clicking the toggle; used by the global shortcut.
    func toggleFromShortcut() { toggleFromMenu() }

    @objc private func toggleFromMenu() { if store.revealMode == .panel { togglePanel() } else { state.toggle(); apply() } }
    @objc private func searchFromMenu() { openSearch() }
    @objc private func settingsFromMenu() { openSettings() }
}
