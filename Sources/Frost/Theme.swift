import SwiftUI
import AppKit

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

    /// Default. Pale ice, slate glass and one cyan accent.
    static let frost = Style(
        name: "Frost", dark: true, ink: hex(0xEAF4FB), veil: hex(0x0B1A26, 0.5),
        cardOpacity: 0.07, strokeOpacity: 0.12, hairlineOpacity: 0.1, accent: hex(0x7FD8F2),
        glowA: hex(0x3A86B5, 0.5), glowB: hex(0xBFE9F7, 0.18), swatch: [0x1B3A52, 0x3A86B5],
        cardRadius: 20, controlRadius: 12, displayDesign: .rounded, material: .hudWindow,
        onAccent: hex(0x06222E))

    /// Deep blue glass with a soft periwinkle accent.
    static let midnight = Style(
        name: "Midnight", dark: true, ink: hex(0xEEF1FA), veil: hex(0x050A1C, 0.55),
        cardOpacity: 0.07, strokeOpacity: 0.12, hairlineOpacity: 0.1, accent: hex(0x9DA9FF),
        glowA: hex(0x3B4BA8, 0.5), glowB: hex(0x6B5BC4, 0.2), swatch: [0x0F1740, 0x3B4BA8],
        cardRadius: 22, controlRadius: 14, displayDesign: .default, material: .hudWindow,
        onAccent: hex(0x0B1033))

    /// Near-monochrome dark blur, one lime accent, tighter corners, serif display.
    static let mono = Style(
        name: "Mono", dark: true, ink: hex(0xF2F2EE), veil: hex(0x08090B, 0.5),
        cardOpacity: 0.05, strokeOpacity: 0.1, hairlineOpacity: 0.09, accent: hex(0xC8F560),
        glowA: hex(0x39414F, 0.55), glowB: hex(0x20262E, 0.5), swatch: [0x14161A, 0x39414F],
        cardRadius: 8, controlRadius: 6, displayDesign: .serif, material: .hudWindow,
        onAccent: hex(0x10130A))

    /// Warm light paper and a clay accent, for people who dislike dark glass.
    static let paper = Style(
        name: "Paper", dark: false, ink: hex(0x2A2620), veil: hex(0xF7F1E6, 0.55),
        cardOpacity: 0.06, strokeOpacity: 0.1, hairlineOpacity: 0.1, accent: hex(0xB5532B),
        glowA: hex(0xF0D9B5, 0.7), glowB: hex(0xFFFFFF, 0.5), swatch: [0xF3EBDC, 0xE2CFA8],
        cardRadius: 18, controlRadius: 12, displayDesign: .serif, material: .popover,
        onAccent: .white)

    static let all = [frost, midnight, mono, paper]
    static func named(_ n: String) -> Style { all.first { $0.name == n } ?? frost }
}

/// Current look. Nothing else hard-codes colour.
enum Theme {
    static var style = Style.frost

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
