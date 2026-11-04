import SwiftUI
import AppKit

/// Small uppercase label in the accent colour with a hairline running to the edge.
struct SectionTitle: View {
    var text: String
    var body: some View {
        HStack(spacing: 14) {
            Text(text.uppercased()).font(.system(size: 12, weight: .semibold)).tracking(2.2).foregroundStyle(Theme.accent)
            Rectangle().fill(Theme.hairline).frame(height: 1)
        }
    }
}

/// A titled group of rows.
struct Block<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title { SectionTitle(text: title).padding(.bottom, 4) }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Note: View {
    var text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text).font(.system(size: 12)).foregroundStyle(Theme.textDim).fixedSize(horizontal: false, vertical: true).padding(.horizontal, 4)
    }
}

/// Rows sit directly on the window, separated by hairlines (no boxes).
struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View { VStack(spacing: 0) { content } }
}

struct Sep: View { var body: some View { Rectangle().fill(Theme.hairline).frame(height: 1) } }

/// Label (and optional hint) on the left, any control on the right.
struct Row<Control: View>: View {
    var title: String
    var subtitle: String?
    @ViewBuilder var control: Control
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.system(size: 14, weight: .medium)).foregroundStyle(Theme.ink)
                if let subtitle { Text(subtitle).font(.system(size: 12)).foregroundStyle(Theme.textDim).fixedSize(horizontal: false, vertical: true) }
            }
            Spacer(minLength: 12)
            control
        }
        .padding(.vertical, 12)
        .frame(minHeight: 52)
    }
}

struct ToggleRow: View {
    var title: String
    var subtitle: String?
    @Binding var isOn: Bool
    var body: some View { Row(title: title, subtitle: subtitle) { Switch(label: title, isOn: $isOn) } }
}

struct MenuRow<T: Hashable>: View {
    var title: String
    var subtitle: String?
    @Binding var selection: T
    var options: [(T, String)]
    var body: some View { Row(title: title, subtitle: subtitle) { Dropdown(label: title, selection: $selection, options: options) } }
}

/// Shared metrics so every control in a row lines up.
enum Control {
    static let height: CGFloat = 30
    static var radius: CGFloat { Theme.controlRadius }
    static var fill: Color { Theme.ink(0.1) }
}

struct ControlButton: ButtonStyle {
    var primary = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium)).foregroundStyle(primary ? Theme.onAccentText : Theme.ink)
            .padding(.horizontal, 12).frame(height: Control.height)
            .background(primary ? Theme.accent : Control.fill, in: RoundedRectangle(cornerRadius: Control.radius))
            .opacity(configuration.isPressed ? 0.7 : 1)
            .pressSpring(configuration.isPressed)
    }
}

/// On/off switch drawn by us so it looks the same whether or not the window is active.
struct Switch: View {
    var label: String
    @Binding var isOn: Bool
    var body: some View {
        Button { isOn.toggle() } label: {
            Capsule().fill(isOn ? Theme.accent : Theme.ink(0.18))
                .frame(width: 44, height: 26)
                .overlay(alignment: isOn ? .trailing : .leading) {
                    Circle().fill(.white).frame(width: 22, height: 22).padding(2).shadow(color: .black.opacity(0.25), radius: 1.5, y: 1)
                }
                .animation(Theme.reduceMotion ? nil : .easeOut(duration: 0.15), value: isOn)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

/// Pop-up menu styled like the other controls: current value plus an up/down chevron.
struct Dropdown<T: Hashable>: View {
    var label: String
    @Binding var selection: T
    var options: [(T, String)]
    var body: some View {
        Menu {
            Picker(label, selection: $selection) { ForEach(options, id: \.0) { Text($0.1).tag($0.0) } }.pickerStyle(.inline)
        } label: {
            HStack(spacing: 8) {
                Text(options.first { $0.0 == selection }?.1 ?? "").lineLimit(1)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .bold)).foregroundStyle(Theme.textDim)
            }
            .font(.system(size: 13, weight: .medium)).foregroundStyle(Theme.ink)
            .padding(.horizontal, 10).frame(height: Control.height)
            .background(Control.fill, in: RoundedRectangle(cornerRadius: Control.radius))
        }
        .menuStyle(.button).menuIndicator(.hidden).buttonStyle(.plain).fixedSize()
        .accessibilityLabel(label)
    }
}
