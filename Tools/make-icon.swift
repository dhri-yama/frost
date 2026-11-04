// Draws Frost's app icon and writes an .iconset folder. Run through ./make-icon.sh, which turns it into Resources/AppIcon.icns.
import AppKit

func hex(_ v: UInt32, _ a: CGFloat = 1) -> NSColor {
    NSColor(srgbRed: CGFloat((v >> 16) & 0xFF) / 255, green: CGFloat((v >> 8) & 0xFF) / 255, blue: CGFloat(v & 0xFF) / 255, alpha: a)
}

func icon(size s: CGFloat) -> NSImage {
    NSImage(size: NSSize(width: s, height: s), flipped: false) { _ in
        let inset = s * 0.1
        let body = NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
        let squircle = NSBezierPath(roundedRect: body, xRadius: body.width * 0.225, yRadius: body.width * 0.225)

        // Soft drop shadow under the icon body.
        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
        shadow.shadowBlurRadius = s * 0.025
        shadow.shadowOffset = NSSize(width: 0, height: -s * 0.012)
        shadow.set()
        hex(0x2F6F9F).setFill(); squircle.fill()
        NSGraphicsContext.restoreGraphicsState()

        // Cold gradient body, light at the top left.
        squircle.addClip()
        NSGradient(colors: [hex(0xBFEAFB), hex(0x6FC3E8), hex(0x2F6F9F), hex(0x1B3A52)],
                   atLocations: [0, 0.35, 0.75, 1], colorSpace: .sRGB)!.draw(in: body, angle: -60)
        // A faint frosted highlight across the top.
        NSGradient(colors: [NSColor.white.withAlphaComponent(0.35), NSColor.white.withAlphaComponent(0)])!
            .draw(in: NSRect(x: body.minX, y: body.midY, width: body.width, height: body.height / 2), angle: -90)

        // The menu bar: a pill holding icons that fade away to a chevron.
        let pill = NSRect(x: body.minX + body.width * 0.14, y: body.midY - body.height * 0.11, width: body.width * 0.72, height: body.height * 0.22)
        let pillPath = NSBezierPath(roundedRect: pill, xRadius: pill.height / 2, yRadius: pill.height / 2)
        NSGraphicsContext.saveGraphicsState()
        let ps = NSShadow()
        ps.shadowColor = NSColor(srgbRed: 0.05, green: 0.15, blue: 0.25, alpha: 0.35)
        ps.shadowBlurRadius = s * 0.02
        ps.shadowOffset = NSSize(width: 0, height: -s * 0.01)
        ps.set()
        NSColor.white.withAlphaComponent(0.94).setFill(); pillPath.fill()
        NSGraphicsContext.restoreGraphicsState()

        // Three icons, each fainter than the last: they are being hidden.
        let r = pill.height * 0.22
        for (i, alpha) in [CGFloat(0.9), 0.55, 0.25].enumerated() {
            let cx = pill.minX + pill.height * 0.7 + CGFloat(i) * pill.height * 0.62
            hex(0x1B3A52, alpha).setFill()
            NSBezierPath(ovalIn: NSRect(x: cx - r, y: pill.midY - r, width: r * 2, height: r * 2)).fill()
        }

        // The chevron, in the accent colour.
        let c = NSBezierPath()
        let cx = pill.maxX - pill.height * 0.62, h = pill.height * 0.24
        c.move(to: NSPoint(x: cx + h * 0.5, y: pill.midY + h))
        c.line(to: NSPoint(x: cx - h * 0.5, y: pill.midY))
        c.line(to: NSPoint(x: cx + h * 0.5, y: pill.midY - h))
        c.lineWidth = pill.height * 0.12
        c.lineCapStyle = .round; c.lineJoinStyle = .round
        hex(0x1F8FB8).setStroke(); c.stroke()
        return true
    }
}

func write(_ image: NSImage, to path: String) {
    guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff),
          let png = rep.representation(using: .png, properties: [:]) else { fatalError("could not encode \(path)") }
    try! png.write(to: URL(fileURLWithPath: path))
}

let out = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.iconset"
try? FileManager.default.createDirectory(atPath: out, withIntermediateDirectories: true)
// The sizes macOS expects: name -> pixel size.
let sizes: [(String, CGFloat)] = [("16x16", 16), ("16x16@2x", 32), ("32x32", 32), ("32x32@2x", 64), ("128x128", 128), ("128x128@2x", 256),
                                  ("256x256", 256), ("256x256@2x", 512), ("512x512", 512), ("512x512@2x", 1024)]
for (name, px) in sizes {
    // Draw at exactly the pixel size (1 point = 1 pixel) so the PNG has the right dimensions.
    let img = icon(size: px)
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(px), pixelsHigh: Int(px), bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    img.draw(in: NSRect(x: 0, y: 0, width: px, height: px))
    NSGraphicsContext.restoreGraphicsState()
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "\(out)/icon_\(name).png"))
}
print("Wrote \(out)")
