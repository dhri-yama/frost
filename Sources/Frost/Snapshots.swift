import SwiftUI
import AppKit
import FrostCore

/// Renders the settings window to PNGs without showing it: `Frost --snapshot <folder>`.
/// The real macOS background blur is not captured, so images show only the tint and glows.
enum Snapshots {
    @MainActor static func run(into folder: String) {
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        // A throwaway defaults suite, so rendering every theme never changes the user's saved settings.
        let suite = "io.github.dhri-yama.frost.snapshot"
        UserDefaults().removePersistentDomain(forName: suite)
        let store = SettingsStore(defaults: UserDefaults(suiteName: suite)!)
        defer { UserDefaults().removePersistentDomain(forName: suite) }
        store.profiles = [Profile(name: "Presenting", hiddenOwners: ["Dropbox", "1Password", "Docker Desktop", "Slack"]),
                          Profile(name: "Home", hiddenOwners: ["Docker Desktop"])]
        Theme.snapshot = true
        let items = ItemsModel()
        func sample(_ id: Int, _ name: String, _ title: String? = nil) -> ItemRow { ItemRow(item: MenuBarItem(windowID: id, pid: 0, ownerName: name, minX: 0, width: 24, title: title, bundleID: "sample.\(id)"), icon: nil) }
        items.trusted = false
        items.source = .accessibility
        items.method = .allowList
        items.visible = [sample(1, "Control Center"), sample(2, "Clock"), sample(3, "Wi-Fi")]
        items.hidden = [sample(4, "Dropbox"), sample(5, "1Password", "Locked"), sample(6, "Docker Desktop")]
        for style in Style.all {
            store.themeName = style.name
            let panel = PanelView(items: items) { _ in }.padding(20).background(style.dark ? Style.hex(0x10131A) : Style.hex(0xE9E2D4))
            let r = ImageRenderer(content: panel); r.scale = 2
            if let img = r.nsImage, let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
                try? png.write(to: URL(fileURLWithPath: folder).appendingPathComponent("panel-\(style.name.lowercased()).png"))
            }
        }
        Theme.style = Style.night
        for step in OnboardingStep.allCases {
            let view = OnboardingView(items: items, store: store, initialStep: step, moveChevron: { _ in }, openSettings: {}, finish: {})
                .background(Style.hex(0x10131A))
            let r = ImageRenderer(content: view); r.scale = 2
            if let img = r.nsImage, let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff), let png = rep.representation(using: .png, properties: [:]) {
                try? png.write(to: URL(fileURLWithPath: folder).appendingPathComponent("onboarding-\(step.rawValue)-\(step).png"))
            }
        }
        for pane in Pane.allCases { for style in Style.all {
            store.themeName = style.name
            let view = SettingsView(store: store, items: items, initialPane: pane)
                .background(style.dark ? Style.hex(0x10131A) : Style.hex(0xE9E2D4))
                .environment(\.colorScheme, Theme.scheme)
            let r = ImageRenderer(content: view)
            r.scale = 2
            guard let img = r.nsImage, let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
                  let png = rep.representation(using: .png, properties: [:]) else { continue }
            try? png.write(to: URL(fileURLWithPath: folder).appendingPathComponent("\(pane.rawValue)-\(style.name.lowercased()).png"))
        } }
    }
}
