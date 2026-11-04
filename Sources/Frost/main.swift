import AppKit
import SwiftUI
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = SettingsStore()
    let items = ItemsModel()
    var menuBar: MenuBarController!
    var search: SearchController!
    let hotkeys = Hotkeys()
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBar = MenuBarController(store: store, items: items)
        items.dividerWindowID = { [unowned self] in menuBar.dividerWindowID }
        items.dividerMinX = { [unowned self] in menuBar.dividerMinX }
        items.prepareForMove = { [unowned self] in menuBar.prepareForMove() }
        items.finishMove = { [unowned self] in menuBar.finishMove() }
        items.toggleMinX = { [unowned self] in menuBar.toggleMinX }
        items.barY = { [unowned self] in menuBar.barY }
        items.ownWindowIDs = { [unowned self] in menuBar.ownWindowIDs }
        search = SearchController(items: items)
        hotkeys.register(key: kVK_ANSI_H) { [unowned self] in if store.shortcutsEnabled { menuBar.toggleFromShortcut() } }
        hotkeys.register(key: kVK_Space) { [unowned self] in if store.shortcutsEnabled { search.toggle() } }
        hotkeys.register(key: kVK_ANSI_P) { [unowned self] in if store.shortcutsEnabled { store.presenting.toggle() } }
        menuBar.openSearch = { [unowned self] in search.show() }
        menuBar.openSettings = { [weak self] in self?.showSettings() }
        if CommandLine.arguments.contains("--settings") { showSettings() }
    }

    func showSettings() {
        if settingsWindow == nil {
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 720, height: 600),
                             styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
            w.titlebarAppearsTransparent = true
            w.titleVisibility = .hidden
            w.isReleasedWhenClosed = false
            w.contentView = NSHostingView(rootView: SettingsView(store: store, items: items))
            w.center()
            settingsWindow = w
        }
        items.refresh()
        settingsWindow?.appearance = Theme.appearance
        NSApp.activate(ignoringOtherApps: true)
        settingsWindow?.makeKeyAndOrderFront(nil)
    }
}

if let i = CommandLine.arguments.firstIndex(of: "--snapshot"), i + 1 < CommandLine.arguments.count {
    MainActor.assumeIsolated { Snapshots.run(into: CommandLine.arguments[i + 1]) }
    exit(0)
}

if CommandLine.arguments.contains("--scan") {
    let items = ItemsModel()
    let done = DispatchSemaphore(value: 0)
    items.refresh()
    DispatchQueue.global().async {
        while items.scanning { usleep(50_000) }
        done.signal()
    }
    // refresh() publishes on the main queue, so spin it until the scan finishes.
    while done.wait(timeout: .now() + .milliseconds(20)) == .timedOut { RunLoop.main.run(until: Date().addingTimeInterval(0.02)) }
    print("Frost \(AppInfo.version): Accessibility \(items.trusted ? "granted" : "NOT granted (this terminal needs it)"); \(items.all.count) item(s) via \(items.source == .accessibility ? "Accessibility" : "the window list")")
    for r in items.all { print(String(format: "%8.0f  %@%@", r.item.minX, r.item.ownerName, r.item.title.map { " – \($0)" } ?? "")) }
    exit(0)
}

if CommandLine.arguments.contains("--length-lab") {
    let app = NSApplication.shared
    app.setActivationPolicy(.accessory)
    let lab = LengthLab()
    lab.start()
    app.run()
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
