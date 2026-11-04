import SwiftUI
import ServiceManagement
import FrostCore

/// User settings, persisted in UserDefaults. Changing the theme restyles every view that observes the store.
final class SettingsStore: ObservableObject {
    private let defaults: UserDefaults

    @Published var themeName: String { didSet { defaults.set(themeName, forKey: "themeName"); Theme.style = Style.named(themeName) } }
    @Published var autoHide: AutoHide { didSet { defaults.set(autoHide.rawValue, forKey: "autoHide"); onAutoHideChange?() } }
    @Published var revealTrigger: RevealTrigger { didSet { defaults.set(revealTrigger.rawValue, forKey: "revealTrigger") } }
    @Published var revealMode: RevealMode { didSet { defaults.set(revealMode.rawValue, forKey: "revealMode") } }
    @Published var shortcutsEnabled: Bool { didSet { defaults.set(shortcutsEnabled, forKey: "shortcutsEnabled") } }
    @Published var hideOnLaunch: Bool { didSet { defaults.set(hideOnLaunch, forKey: "hideOnLaunch") } }
    @Published var profiles: [Profile] { didSet { defaults.set(try? JSONEncoder().encode(profiles), forKey: "profiles") } }
    /// Presenting mode keeps everything hidden until switched off. Deliberately not saved: it never survives a relaunch.
    /// Apps whose menu bar items are hidden (macOS 27 allow-list). Stored by bundle identifier.
    @Published var hiddenBundleIDs: Set<String> { didSet { defaults.set(hiddenBundleIDs.sorted(), forKey: "hiddenBundleIDs"); onHiddenChange?() } }
    @Published var presenting = false { didSet { onPresentingChange?() } }
    @Published var launchAtLogin: Bool { didSet { if !syncingLogin { setLoginItem(launchAtLogin) } } }
    @Published var loginError: String?

    var onHiddenChange: (() -> Void)?
    var onAutoHideChange: (() -> Void)?
    var onPresentingChange: (() -> Void)?
    private var syncingLogin = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let name = defaults.string(forKey: "themeName") ?? Style.frost.name
        themeName = name
        autoHide = AutoHide(rawValue: defaults.object(forKey: "autoHide") as? Int ?? AutoHide.tenSeconds.rawValue) ?? .tenSeconds
        revealTrigger = RevealTrigger(rawValue: defaults.object(forKey: "revealTrigger") as? Int ?? 0) ?? .click
        revealMode = RevealMode(rawValue: defaults.object(forKey: "revealMode") as? Int ?? 0) ?? .inline
        shortcutsEnabled = defaults.object(forKey: "shortcutsEnabled") as? Bool ?? true
        hideOnLaunch = defaults.object(forKey: "hideOnLaunch") as? Bool ?? true
        hiddenBundleIDs = Set(defaults.stringArray(forKey: "hiddenBundleIDs") ?? [])
        profiles = defaults.data(forKey: "profiles").flatMap { try? JSONDecoder().decode([Profile].self, from: $0) } ?? []
        launchAtLogin = SMAppService.mainApp.status == .enabled
        Theme.style = Style.named(name)
    }

    func toggleHidden(_ bundleID: String) {
        if hiddenBundleIDs.contains(bundleID) { hiddenBundleIDs.remove(bundleID) } else { hiddenBundleIDs.insert(bundleID) }
    }

    private func setLoginItem(_ on: Bool) {
        do {
            if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
            loginError = nil
        } catch {
            // Registration fails for unsigned or non-bundled builds; put the switch back and say why.
            loginError = "Could not change the login item: \(error.localizedDescription)"
            syncingLogin = true; launchAtLogin = !on; syncingLogin = false
        }
    }
}

enum AppInfo {
    static var version: String { Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "dev" }
}
