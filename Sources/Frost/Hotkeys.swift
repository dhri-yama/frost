import Carbon.HIToolbox
import FrostCore

/// Global shortcuts via Carbon's RegisterEventHotKey (works without any permission). Bindings can be replaced at any time.
final class Hotkeys {
    private var actions: [UInt32: () -> Void] = [:]
    private var refs: [EventHotKeyRef] = []

    init() {
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            var id = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil,
                              MemoryLayout<EventHotKeyID>.size, nil, &id)
            let me = Unmanaged<Hotkeys>.fromOpaque(userData!).takeUnretainedValue()
            me.actions[id.id]?()
            return noErr
        }, 1, &spec, Unmanaged.passUnretained(self).toOpaque(), nil)
    }

    /// Replaces every registration with these. Returns the actions the system refused, usually because another app owns
    /// that shortcut.
    @discardableResult
    func set(_ bindings: [(action: ShortcutAction, shortcut: Shortcut, run: () -> Void)]) -> Set<ShortcutAction> {
        refs.forEach { UnregisterEventHotKey($0) }
        refs = []; actions = [:]
        var failed = Set<ShortcutAction>()
        for (i, b) in bindings.enumerated() {
            let id = UInt32(i + 1)
            var ref: EventHotKeyRef?
            let status = RegisterEventHotKey(UInt32(b.shortcut.keyCode), b.shortcut.modifiers, EventHotKeyID(signature: 0x46525354, id: id),
                                             GetApplicationEventTarget(), 0, &ref)
            if status == noErr, let ref { refs.append(ref); actions[id] = b.run } else { failed.insert(b.action) }
        }
        return failed
    }
}
