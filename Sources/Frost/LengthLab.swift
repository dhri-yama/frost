import AppKit

/// Diagnostic: `Frost --length-lab`. Uses the same two status items as the real app (same saved positions) and steps the
/// divider through several widths every few seconds, showing the current width on the chevron, so you can see at which
/// width the icons left of the divider disappear on this macOS version. Prints the item window frames as it goes.
final class LengthLab {
    private let toggle = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let divider = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let lengths: [CGFloat] = [18, 300, 800, 1500, 2500, 5000, 10000]
    private var i = 0

    func start() {
        toggle.autosaveName = "frost.toggle"
        divider.autosaveName = "frost.divider"
        step()
        Timer.scheduledTimer(withTimeInterval: 6, repeats: true) { [weak self] _ in self?.step() }
    }

    private func step() {
        let l = lengths[i % lengths.count]; i += 1
        divider.length = l
        divider.button?.title = ""
        toggle.button?.title = " \(Int(l))"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [self] in
            let d = divider.button?.window?.frame ?? .zero, t = toggle.button?.window?.frame ?? .zero
            print("divider length \(Int(l)): divider frame \(d), toggle frame \(t)")
            fflush(stdout)
        }
    }
}
