import SwiftUI
import AppKit

/// Renders the settings window to PNGs without showing it: `Frost --snapshot <folder>`.
/// The real macOS background blur is not captured, so images show only the tint and glows.
enum Snapshots {
    @MainActor static func run(into folder: String) {
        try? FileManager.default.createDirectory(atPath: folder, withIntermediateDirectories: true)
        let store = SettingsStore()
        Theme.snapshot = true
        for style in Style.all {
            store.themeName = style.name
            let view = SettingsView(store: store)
                .background(Style.hex(0x10131A))
                .environment(\.colorScheme, Theme.scheme)
            let r = ImageRenderer(content: view)
            r.scale = 2
            guard let img = r.nsImage, let tiff = img.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
                  let png = rep.representation(using: .png, properties: [:]) else { continue }
            try? png.write(to: URL(fileURLWithPath: folder).appendingPathComponent("settings-\(style.name.lowercased()).png"))
        }
    }
}
