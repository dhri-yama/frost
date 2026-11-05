import SwiftUI
import ServiceManagement
import FrostCore

/// User settings, persisted in UserDefaults. Changing the theme restyles every view that observes the store.
final class SettingsStore: ObservableObject {
    private let defaults: UserDefaults

    @Published var themeName: String { didSet { defaults.set(themeName, forKey: "themeName"); Theme.style = Style.named(themeName) } }
    @Published var autoHide: AutoHide { didSet { defaults.set(autoHide.rawValue, forKey: "autoHide"); onAutoHideChange?() } }
    @Published var menuBarIcon: MenuBarIcon { didSet { defaults.set(menuBarIcon.rawValue, forKey: "menuBarIcon"); onIconChange?() } }
    @Published var revealMode: RevealMode { didSet { defaults.set(revealMode.rawValue, forKey: "revealMode") } }
    @Published var shortcutsEnabled: Bool { didSet { defaults.set(shortcutsEnabled, forKey: "shortcutsEnabled"); onShortcutsChange?() } }
    @Published var shortcuts: ShortcutSet { didSet { defaults.set(try? JSONEncoder().encode(shortcuts), forKey: "shortcuts"); onShortcutsChange?() } }
    /// Shortcuts the system refused to register (usually another app already uses them). Set by the app delegate.
    @Published var shortcutFailures: Set<ShortcutAction> = []
    /// Whether the first-run setup has been shown.
    @Published var didOnboard: Bool { didSet { defaults.set(didOnboard, forKey: "didOnboard") } }
    @Published var hideOnLaunch: Bool { didSet { defaults.set(hideOnLaunch, forKey: "hideOnLaunch") } }
    @Published var profiles: [Profile] { didSet { defaults.set(try? JSONEncoder().encode(profiles), forKey: "profiles") } }
    /// Presenting mode keeps everything hidden until switched off. Deliberately not saved: it never survives a relaunch.
    /// Apps whose menu bar items are hidden (macOS 27 allow-list). Stored by bundle identifier.
    @Published var hiddenBundleIDs: Set<String> { didSet { defaults.set(hiddenBundleIDs.sorted(), forKey: "hiddenBundleIDs"); onHiddenChange?() } }
    /// `.chosen`: hide the apps in `hiddenBundleIDs`. `.allExcept`: hide every running app not in `keepVisibleBundleIDs`.
    @Published var hideMode: HideMode { didSet { defaults.set(hideMode.rawValue, forKey: "hideMode"); onHiddenChange?() } }
    @Published var keepVisibleBundleIDs: Set<String> { didSet { defaults.set(keepVisibleBundleIDs.sorted(), forKey: "keepVisibleBundleIDs"); onHiddenChange?() } }
    @Published var presenting = false { didSet { onPresentingChange?() } }
    @Published var launchAtLogin: Bool { didSet { if !syncingLogin { setLoginItem(launchAtLogin) } } }
    @Published var loginError: String?

    var onShortcutsChange: (() -> Void)?
    var onIconChange: (() -> Void)?
    var onHiddenChange: (() -> Void)?
    /// Opens the first-run setup again; set by the app delegate.
    var showSetup: (() -> Void)?
    var onAutoHideChange: (() -> Void)?
    var onPresentingChange: (() -> Void)?
    private var syncingLogin = false

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let name = ThemeName.resolve(defaults.string(forKey: "themeName"))
        themeName = name
        autoHide = AutoHide(rawValue: defaults.object(forKey: "autoHide") as? Int ?? AutoHide.tenSeconds.rawValue) ?? .tenSeconds
        menuBarIcon = MenuBarIcon.resolve(rawValue: defaults.object(forKey: "menuBarIcon") as? Int)
        revealMode = RevealMode(rawValue: defaults.object(forKey: "revealMode") as? Int ?? 0) ?? .inline
        shortcutsEnabled = defaults.object(forKey: "shortcutsEnabled") as? Bool ?? true
        shortcuts = defaults.data(forKey: "shortcuts").flatMap { try? JSONDecoder().decode(ShortcutSet.self, from: $0) } ?? ShortcutSet()
        didOnboard = defaults.object(forKey: "didOnboard") as? Bool ?? false
        hideOnLaunch = defaults.object(forKey: "hideOnLaunch") as? Bool ?? true
        hiddenBundleIDs = Set(defaults.stringArray(forKey: "hiddenBundleIDs") ?? [])
        hideMode = HideMode(rawValue: defaults.object(forKey: "hideMode") as? Int ?? 0) ?? .chosen
        keepVisibleBundleIDs = Set(defaults.stringArray(forKey: "keepVisibleBundleIDs") ?? [])
        profiles = defaults.data(forKey: "profiles").flatMap { try? JSONDecoder().decode([Profile].self, from: $0) } ?? []
        launchAtLogin = SMAppService.mainApp.status == .enabled
        Theme.style = Style.named(name)
    }

    /// The bundle identifiers to hide right now, which depends on the mode and, in `.allExcept`, on what is running.
    func effectiveHidden() -> Set<String> {
        let running = Set(NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier))
        let never = Set([Bundle.main.bundleIdentifier].compactMap { $0 })
        return HiddenResolver.hidden(mode: hideMode, chosen: hideMode == .chosen ? hiddenBundleIDs : keepVisibleBundleIDs, running: running, neverHide: never)
    }

    /// Hides or shows an app, whichever mode is on (in `.allExcept` mode "hide" means taking it off the keep-visible list).
    func setHidden(_ bundleID: String, _ hidden: Bool) {
        switch hideMode {
        case .chosen:
            if hidden { hiddenBundleIDs.insert(bundleID) } else { hiddenBundleIDs.remove(bundleID) }
        case .allExcept:
            if hidden { keepVisibleBundleIDs.remove(bundleID) } else { keepVisibleBundleIDs.insert(bundleID) }
        }
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
