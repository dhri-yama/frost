import SwiftUI
import FrostCore

/// Steps of the first-run setup. Each one explains a requirement before asking for anything.
enum OnboardingStep: Int, CaseIterable {
    case welcome, install, accessibility, chevron, done

    var title: String {
        switch self {
        case .welcome: return "Welcome to Frost"
        case .install: return "Where Frost lives"
        case .chevron: return "Place the chevron"
        case .accessibility: return "Accessibility"
        case .done: return "You're set"
        }
    }

    var blurb: String {
        switch self {
        case .welcome: return "Hide the menu bar icons you don't need, and bring them back with one click."
        case .install: return "On macOS 27, hiding only works when Frost runs from the Applications folder."
        case .chevron: return "Hidden icons appear on the chevron's left, so it belongs at the right edge."
        case .accessibility: return "Optional. Hiding works without it."
        case .done: return "Choose what to hide in Settings."
        }
    }
}

final class OnboardingModel: ObservableObject {
    @Published var step: OnboardingStep
    @Published var moving = false
    @Published var moveResult: String?
    @Published var trusted = AccessibilityScan.trusted
    init(_ step: OnboardingStep = .welcome) { self.step = step }

    func next() { if let n = OnboardingStep(rawValue: step.rawValue + 1) { step = n } }
    func back() { if let p = OnboardingStep(rawValue: step.rawValue - 1) { step = p } }
}

struct OnboardingView: View {
    @ObservedObject var items: ItemsModel
    @StateObject private var model: OnboardingModel
    var moveChevron: (@escaping (Bool) -> Void) -> Void
    var openSettings: () -> Void
    var finish: () -> Void

    init(items: ItemsModel, initialStep: OnboardingStep = .welcome, moveChevron: @escaping (@escaping (Bool) -> Void) -> Void,
         openSettings: @escaping () -> Void, finish: @escaping () -> Void) {
        self.items = items; self.moveChevron = moveChevron; self.openSettings = openSettings; self.finish = finish
        _model = StateObject(wrappedValue: OnboardingModel(initialStep))
    }

    private var installed: Bool { Bundle.main.bundlePath.hasPrefix("/Applications/") }
    private var needsInstallStep: Bool { items.method == .allowList || items.needsInstall }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                ForEach(OnboardingStep.allCases, id: \.self) { s in
                    Capsule().fill(s.rawValue <= model.step.rawValue ? Theme.accent : Theme.ink(0.18)).frame(height: 4)
                }
            }
            .padding(.top, 40)
            VStack(alignment: .leading, spacing: 8) {
                Text(model.step.title).font(Theme.display(34, .bold)).foregroundStyle(Theme.ink)
                Text(model.step.blurb).font(.system(size: 15)).foregroundStyle(Theme.textDim)
            }
            .padding(.top, 28)
            content.padding(.top, 24)
            Spacer(minLength: 16)
            HStack {
                if model.step != .welcome { Button("Back") { model.back() }.buttonStyle(ControlButton()) }
                Spacer()
                if model.step == .done {
                    Button("Open Settings") { openSettings(); finish() }.buttonStyle(ControlButton())
                    Button("Done") { finish() }.buttonStyle(ControlButton(primary: true))
                } else {
                    Button(model.step == .welcome ? "Get started" : "Continue") { model.next() }.buttonStyle(ControlButton(primary: true))
                }
            }
            .padding(.bottom, 28)
        }
        .padding(.horizontal, 44)
        .frame(width: 560, height: 520)
        .background { ZStack { if !Theme.snapshot { Glass(material: Theme.style.material) }; Theme.glow }.ignoresSafeArea() }
        .environment(\.colorScheme, Theme.scheme)
    }

    @ViewBuilder private var content: some View {
        switch model.step {
        case .welcome:
            VStack(alignment: .leading, spacing: 14) {
                point("chevron.left", "Click the chevron to show or hide your icons.")
                point("eye.slash", "Pick which apps to hide in Settings → Layout. Hiding is per app.")
                point("lock.shield", "No accounts, no tracking, nothing leaves your Mac.")
            }
        case .install:
            if !needsInstallStep {
                status(true, "Not needed on this version of macOS. Frost hides icons with a divider here.")
            } else if installed {
                status(true, "Frost is running from Applications.")
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    status(false, "Frost is not in Applications, so it cannot hide anything yet.")
                    Note("Quit Frost, move Frost.app into /Applications (or run ./install.sh from the source folder), and open it from there. Come back to this setup from Settings → About.")
                }
            }
        case .chevron:
            VStack(alignment: .leading, spacing: 12) {
                Text("Frost's chevron (‹) sits wherever macOS puts it. Moving it just left of the Control Center icon makes hidden icons open out to its left, and keeps the chevron where it is.")
                    .font(.system(size: 14)).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    Button(model.moving ? "Moving…" : "Move it for me") {
                        model.moving = true; model.moveResult = nil
                        moveChevron { ok in
                            model.moving = false
                            model.moveResult = ok ? "Done. Check the chevron's position in the menu bar." : "Could not move it. Use the manual way below."
                        }
                    }
                    .buttonStyle(ControlButton(primary: true)).disabled(!model.trusted || model.moving).opacity(model.trusted && !model.moving ? 1 : 0.4)
                    if !model.trusted { Text("Needs Accessibility (previous step)").font(.system(size: 12)).foregroundStyle(Theme.textDim) }
                }
                if let r = model.moveResult { Note(r) }
                Note("By hand: hold ⌘ and drag the chevron to just left of the Control Center icon.")
            }
        case .accessibility:
            VStack(alignment: .leading, spacing: 12) {
                Text("Accessibility lets Frost list only apps that really have a menu bar item, click a hidden app's icon for you, and move the chevron. It cannot see your screen or what you type.")
                    .font(.system(size: 14)).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true)
                status(model.trusted, model.trusted ? "Accessibility is allowed." : "Accessibility is not allowed. Frost works without it.")
                HStack(spacing: 8) {
                    Button("Allow") { AccessibilityScan.requestTrust(); recheck() }.buttonStyle(ControlButton(primary: true))
                    Button("Open Settings") { AccessibilityScan.openSettings() }.buttonStyle(ControlButton())
                    Button("Check again") { recheck() }.buttonStyle(ControlButton())
                }
            }
        case .done:
            VStack(alignment: .leading, spacing: 14) {
                point("slider.horizontal.3", "Settings → Layout: press Hide next to the apps you want out of the way.")
                point("magnifyingglass", "⌃⌥Space searches every menu bar item, hidden or not.")
                point("rectangle.on.rectangle", "⌃⌥P keeps everything hidden while you present.")
            }
        }
    }

    private func recheck() { model.trusted = AccessibilityScan.trusted; items.refresh() }

    private func point(_ symbol: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol).font(.system(size: 16)).foregroundStyle(Theme.accent).frame(width: 24)
            Text(text).font(.system(size: 14)).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true)
        }
    }

    private func status(_ ok: Bool, _ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: ok ? "checkmark.circle.fill" : "exclamationmark.triangle.fill").foregroundStyle(ok ? Theme.accent : .orange)
            Text(text).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.ink).fixedSize(horizontal: false, vertical: true)
        }
    }
}
