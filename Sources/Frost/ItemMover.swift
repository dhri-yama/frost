import AppKit
import FrostCore

/// Moves another app's menu bar item across Frost's divider by posting the same ⌘-drag a person would perform.
/// macOS offers no API for this. Needs the Accessibility permission (to post events and to read positions).
enum ItemMover {
    /// Runs on a background queue; blocks for about a second. Returns false if the item or divider could not be found.
    static func move(id: Int, toHidden: Bool, dividerMinX: Double, toggleMinX: Double, barY: Double) -> Bool {
        let fresh = AccessibilityScan.scan()
        guard let item = fresh.first(where: { $0.id == id }),
              MovePlan.needsMove(item: item, toHidden: toHidden, dividerMinX: dividerMinX) else { return false }
        let plan = MovePlan.make(item: item, toHidden: toHidden, dividerMinX: dividerMinX, toggleMinX: toggleMinX, barY: barY)

        let home = CGEvent(source: nil)?.location ?? .zero
        func post(_ type: CGEventType, _ p: MovePoint) {
            let e = CGEvent(mouseEventSource: nil, mouseType: type, mouseCursorPosition: CGPoint(x: p.x, y: p.y), mouseButton: .left)
            e?.flags = .maskCommand
            e?.post(tap: .cghidEventTap)
            usleep(12_000)
        }
        let path = plan.path(steps: 14)
        post(.mouseMoved, path[0])
        post(.leftMouseDown, path[0])
        for p in path.dropFirst() { post(.leftMouseDragged, p) }
        usleep(60_000)
        post(.leftMouseUp, path[path.count - 1])
        let back = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: home, mouseButton: .left)
        back?.post(tap: .cghidEventTap)
        return true
    }
}
