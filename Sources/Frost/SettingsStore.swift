import SwiftUI
import FrostCore

/// User settings, persisted in UserDefaults. Changing the theme restyles every view that observes the store.
final class SettingsStore: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var themeName: String { didSet { defaults.set(themeName, forKey: "themeName"); Theme.style = Style.named(themeName) } }
    @Published var autoHide: AutoHide { didSet { defaults.set(autoHide.rawValue, forKey: "autoHide"); onAutoHideChange?() } }
    @Published var hideOnLaunch: Bool { didSet { defaults.set(hideOnLaunch, forKey: "hideOnLaunch") } }

    var onAutoHideChange: (() -> Void)?

    init() {
        let name = defaults.string(forKey: "themeName") ?? Style.frost.name
        themeName = name
        autoHide = AutoHide(rawValue: defaults.object(forKey: "autoHide") as? Int ?? AutoHide.tenSeconds.rawValue) ?? .tenSeconds
        hideOnLaunch = defaults.object(forKey: "hideOnLaunch") as? Bool ?? true
        Theme.style = Style.named(name)
    }
}

enum AppInfo {
    static var version: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev" }
}
