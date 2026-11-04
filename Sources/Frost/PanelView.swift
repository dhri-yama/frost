import SwiftUI
import FrostCore

/// The second bar: hidden items as icon tiles. Clicking a tile clicks the real menu bar item (Accessibility).
struct PanelView: View {
    @ObservedObject var items: ItemsModel
    var onPick: (ItemRow) -> Void

    var body: some View {
        let size = PanelLayout.size(itemCount: items.hidden.count)
        Group {
            if items.hidden.isEmpty {
                Text(items.trusted ? (items.scanning ? "Looking…" : "Nothing is hidden.") : "Allow Accessibility in Settings to see hidden items.")
                    .font(.system(size: 13)).foregroundStyle(Theme.textDim).multilineTextAlignment(.center).padding(.horizontal, 12)
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(PanelLayout.tile), spacing: PanelLayout.gap), count: min(items.hidden.count, PanelLayout.maxColumns)),
                          spacing: PanelLayout.gap) {
                    ForEach(items.hidden) { r in
                        Button { onPick(r) } label: { tile(r) }
                            .buttonStyle(TileStyle())
                            .help(r.item.title ?? r.item.ownerName)
                            .accessibilityLabel(r.item.title ?? r.item.ownerName)
                    }
                }
            }
        }
        .frame(width: size.width, height: size.height)
        .background { ZStack { if !Theme.snapshot { Glass(material: Theme.style.material) }; Theme.glow } }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay { RoundedRectangle(cornerRadius: Theme.cardRadius).stroke(Theme.cardStroke, lineWidth: 1) }
        .environment(\.colorScheme, Theme.scheme)
    }

    private func tile(_ r: ItemRow) -> some View {
        Group {
            if let icon = r.icon { Image(nsImage: icon).resizable().frame(width: 24, height: 24) }
            else { Image(systemName: "app.dashed").font(.system(size: 18)).foregroundStyle(Theme.textDim) }
        }
        .frame(width: PanelLayout.tile, height: PanelLayout.tile)
    }

    private struct TileStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .background(Theme.ink(configuration.isPressed ? 0.2 : 0.08), in: RoundedRectangle(cornerRadius: Theme.controlRadius))
                .overlay { RoundedRectangle(cornerRadius: Theme.controlRadius).stroke(Theme.accent.opacity(configuration.isPressed ? 0.8 : 0), lineWidth: 1.5) }
                .pressSpring(configuration.isPressed)
        }
    }
}

/// Borderless panel that floats under the menu bar without taking focus from the frontmost app.
final class PanelWindow: NSPanel {
    init(content: NSView) {
        super.init(contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isReleasedWhenClosed = false
        contentView = content
    }
    override var canBecomeKey: Bool { true }   // so Esc reaches us
    override func cancelOperation(_ sender: Any?) { orderOut(nil) }
}
