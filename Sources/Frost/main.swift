import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = SettingsStore()
    let items = ItemsModel()
    var menuBar: MenuBarController!
    var settingsWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBar = MenuBarController(store: store)
        items.dividerWindowID = { [unowned self] in menuBar.dividerWindowID }
        items.ownWindowIDs = { [unowned self] in menuBar.ownWindowIDs }
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
    items.refresh()
    let all = items.hidden + items.visible
    print("Frost \(AppInfo.version): found \(all.count) menu bar item(s) via the window list")
    for r in all { print(String(format: "%8.0f  %@", r.item.minX, r.item.ownerName)) }
    if all.isEmpty { print("None found. On newer macOS versions the system may not expose status items as windows; an Accessibility-based scan is planned.") }
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
