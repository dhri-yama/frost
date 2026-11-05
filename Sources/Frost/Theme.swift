import SwiftUI
import AppKit
import FrostCore

/// Everything that makes one visual direction different from another. Views read `Theme`, which reads `Theme.style`.
struct Style {
    var name: String
    var dark: Bool
    var ink: Color                    // text, icons and translucent fills
    var veil: Color                   // tint over the blurred window
    var cardOpacity: Double           // card fill = ink at this opacity
    var strokeOpacity: Double
    var hairlineOpacity: Double
    var accent: Color
    var glowA: Color
    var glowB: Color
    var swatch: [UInt32]              // theme picker preview gradient
    var cardRadius: CGFloat
    var controlRadius: CGFloat
    var displayDesign: Font.Design    // headings and big numbers
    var material: NSVisualEffectView.Material
    var onAccent: Color = .white      // text on accent-coloured buttons
}

extension Style {
    static func hex(_ v: UInt32, _ a: Double = 1) -> Color {
        Color(red: Double((v >> 16) & 0xFF) / 255, green: Double((v >> 8) & 0xFF) / 255, blue: Double(v & 0xFF) / 255, opacity: a)
    }

    /// The bar after dark: black glass, chalk-white text, and one warm amber, like a lamp over the counter.
    static let night = Style(
        name: "Night", dark: true, ink: hex(0xECE7DF), veil: hex(0x040302, 0.66),
        cardOpacity: 0.06, strokeOpacity: 0.12, hairlineOpacity: 0.1, accent: hex(0xFFB35C),
        glowA: hex(0xFFB35C, 0.17), glowB: hex(0xC77A2E, 0.11), swatch: [0x000000, 0x3A2A18],
        cardRadius: 18, controlRadius: 12, displayDesign: .default, material: .hudWindow,
        onAccent: hex(0x1A1006))

    /// The same bar by day: warm cream light, espresso text and a brass accent, like sun on the counter.
    static let day = Style(
        name: "Day", dark: false, ink: hex(0x2B2118), veil: hex(0xF6EEE0, 0.62),
        cardOpacity: 0.06, strokeOpacity: 0.1, hairlineOpacity: 0.11, accent: hex(0x9A5212),
        glowA: hex(0xFFD9A0, 0.7), glowB: hex(0xFFFFFF, 0.5), swatch: [0xF6EBD6, 0xE3C998],
        cardRadius: 18, controlRadius: 12, displayDesign: .serif, material: .popover,
        onAccent: .white)

    static let all = [day, night]
    /// The theme for a saved name; names from older versions are mapped by `ThemeName.resolve`.
    static func named(_ n: String) -> Style { all.first { $0.name == ThemeName.resolve(n) } ?? night }
}

/// Current look. Nothing else hard-codes colour.
enum Theme {
    static var style = Style.night
    /// True while rendering PNGs: ImageRenderer cannot draw NSViewRepresentable, ScrollView or Menu.
    static var snapshot = false

    static var ink: Color { style.ink }
    static func ink(_ opacity: Double) -> Color { style.ink.opacity(opacity) }
    static var textDim: Color { ink(0.62) }
    static var accent: Color { style.accent }
    static var onAccentText: Color { style.onAccent }
    static var card: Color { ink(style.cardOpacity) }
    static var cardStroke: Color { ink(style.strokeOpacity) }
    static var hairline: Color { ink(style.hairlineOpacity) }
    static var cardRadius: CGFloat { style.cardRadius }
    static var controlRadius: CGFloat { style.controlRadius }
    static var scheme: ColorScheme { style.dark ? .dark : .light }
    static var appearance: NSAppearance? { NSAppearance(named: style.dark ? .darkAqua : .aqua) }

    /// Display face for headings and big numbers.
    static func display(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: style.displayDesign)
    }

    /// Tint plus two soft glows over the blurred window.
    static var glow: some View {
        ZStack {
            style.veil
            RadialGradient(colors: [style.glowA, .clear], center: .topLeading, startRadius: 0, endRadius: 620)
            RadialGradient(colors: [style.glowB, .clear], center: .bottomTrailing, startRadius: 0, endRadius: 560)
        }
    }

    static func swatch(_ style: Style) -> LinearGradient {
        LinearGradient(colors: style.swatch.map { Style.hex($0) }, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    static var reduceMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
}

extension View {
    /// Springy shrink while pressed; skipped under Reduce Motion.
    func pressSpring(_ pressed: Bool) -> some View {
        scaleEffect(pressed ? 0.95 : 1)
            .animation(Theme.reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.55), value: pressed)
    }
}

/// Blurred window material behind SwiftUI content.
struct Glass: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.blendingMode = .behindWindow
        v.state = .active
        v.material = material
        return v
    }
    func updateNSView(_ v: NSVisualEffectView, context: Context) { v.material = material }
}
