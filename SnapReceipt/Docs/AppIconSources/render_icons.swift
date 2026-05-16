import AppKit

struct Palette {
    let backgroundTop: NSColor
    let backgroundBottom: NSColor
    let circleOne: NSColor
    let circleTwo: NSColor
    let paperTop: NSColor
    let paperBottom: NSColor
    let fold: NSColor
    let primaryLine: NSColor
    let secondaryLine: NSColor
    let scanStroke: NSColor
    let scanGlow: NSColor
    let badge: NSColor
    let badgeCheck: NSColor
    let shadow: NSColor
}

let size = CGSize(width: 1024, height: 1024)

let icons: [(path: String, palette: Palette)] = [
    (
        path: "/Users/pekka/work/github/ios-little-apps/SnapReceipt/SnapReceipt/Assets.xcassets/AppIcon.appiconset/icon-standard.png",
        palette: Palette(
            backgroundTop: NSColor(calibratedRed: 1.00, green: 0.71, blue: 0.42, alpha: 1),
            backgroundBottom: NSColor(calibratedRed: 0.65, green: 0.23, blue: 0.22, alpha: 1),
            circleOne: NSColor(calibratedRed: 1.0, green: 0.84, blue: 0.63, alpha: 0.18),
            circleTwo: NSColor(calibratedRed: 0.49, green: 0.12, blue: 0.19, alpha: 0.18),
            paperTop: NSColor(calibratedRed: 1.0, green: 0.98, blue: 0.95, alpha: 1),
            paperBottom: NSColor(calibratedRed: 1.0, green: 0.90, blue: 0.80, alpha: 1),
            fold: NSColor(calibratedRed: 1.0, green: 0.82, blue: 0.60, alpha: 1),
            primaryLine: NSColor(calibratedRed: 0.84, green: 0.36, blue: 0.28, alpha: 1),
            secondaryLine: NSColor(calibratedRed: 0.91, green: 0.60, blue: 0.39, alpha: 1),
            scanStroke: NSColor(calibratedRed: 0.69, green: 0.24, blue: 0.25, alpha: 1),
            scanGlow: NSColor.white.withAlphaComponent(0.85),
            badge: NSColor(calibratedRed: 0.13, green: 0.19, blue: 0.29, alpha: 1),
            badgeCheck: NSColor(calibratedRed: 1.0, green: 0.96, blue: 0.91, alpha: 1),
            shadow: NSColor(calibratedRed: 0.37, green: 0.12, blue: 0.13, alpha: 0.26)
        )
    ),
    (
        path: "/Users/pekka/work/github/ios-little-apps/SnapReceipt/SnapReceipt/Assets.xcassets/AppIcon.appiconset/icon-dark.png",
        palette: Palette(
            backgroundTop: NSColor(calibratedRed: 0.08, green: 0.13, blue: 0.21, alpha: 1),
            backgroundBottom: NSColor(calibratedRed: 0.03, green: 0.06, blue: 0.11, alpha: 1),
            circleOne: NSColor(calibratedRed: 0.11, green: 0.20, blue: 0.34, alpha: 1),
            circleTwo: NSColor(calibratedRed: 0.06, green: 0.14, blue: 0.25, alpha: 1),
            paperTop: NSColor(calibratedRed: 0.97, green: 0.98, blue: 0.99, alpha: 1),
            paperBottom: NSColor(calibratedRed: 0.87, green: 0.91, blue: 0.95, alpha: 1),
            fold: NSColor(calibratedRed: 0.75, green: 0.82, blue: 0.90, alpha: 1),
            primaryLine: NSColor(calibratedRed: 0.11, green: 0.20, blue: 0.34, alpha: 1),
            secondaryLine: NSColor(calibratedRed: 0.31, green: 0.41, blue: 0.54, alpha: 1),
            scanStroke: NSColor(calibratedRed: 0.25, green: 0.84, blue: 1.0, alpha: 1),
            scanGlow: NSColor(calibratedRed: 0.55, green: 0.96, blue: 1.0, alpha: 0.95),
            badge: NSColor(calibratedRed: 0.33, green: 0.87, blue: 1.0, alpha: 1),
            badgeCheck: NSColor(calibratedRed: 0.03, green: 0.07, blue: 0.13, alpha: 1),
            shadow: NSColor(calibratedWhite: 0.0, alpha: 0.35)
        )
    ),
    (
        path: "/Users/pekka/work/github/ios-little-apps/SnapReceipt/SnapReceipt/Assets.xcassets/AppIcon.appiconset/icon-tinted.png",
        palette: Palette(
            backgroundTop: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 1),
            backgroundBottom: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 1),
            circleOne: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 0),
            circleTwo: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 0),
            paperTop: NSColor(calibratedRed: 0.93, green: 0.96, blue: 1.0, alpha: 1),
            paperBottom: NSColor(calibratedRed: 0.93, green: 0.96, blue: 1.0, alpha: 1),
            fold: NSColor(calibratedRed: 0.84, green: 0.89, blue: 0.98, alpha: 1),
            primaryLine: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 1),
            secondaryLine: NSColor(calibratedRed: 0.41, green: 0.50, blue: 0.64, alpha: 1),
            scanStroke: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 1),
            scanGlow: NSColor.clear,
            badge: NSColor(calibratedRed: 0.23, green: 0.31, blue: 0.44, alpha: 1),
            badgeCheck: NSColor(calibratedRed: 0.93, green: 0.96, blue: 1.0, alpha: 1),
            shadow: NSColor.clear
        )
    )
]

func roundedRectPath(_ rect: CGRect, radius: CGFloat) -> NSBezierPath {
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
}

func fillLinearGradient(_ rect: CGRect, top: NSColor, bottom: NSColor, angle: CGFloat = -45) {
    let gradient = NSGradient(colors: [top, bottom])!
    gradient.draw(in: roundedRectPath(rect, radius: rect.width == 1024 ? 224 : 0), angle: angle)
}

func drawIcon(palette: Palette, to path: String) throws {
    let image = NSImage(size: size)
    image.lockFocus()

    let canvas = CGRect(origin: .zero, size: size)
    fillLinearGradient(canvas, top: palette.backgroundTop, bottom: palette.backgroundBottom)

    palette.circleOne.setFill()
    NSBezierPath(ovalIn: CGRect(x: 664, y: 676, width: 236, height: 236)).fill()
    palette.circleTwo.setFill()
    NSBezierPath(ovalIn: CGRect(x: 80, y: 24, width: 328, height: 328)).fill()

    if palette.shadow.alphaComponent > 0 {
        let shadow = NSShadow()
        shadow.shadowColor = palette.shadow
        shadow.shadowOffset = CGSize(width: 0, height: -24)
        shadow.shadowBlurRadius = 26
        shadow.set()
    }

    let paperRect = CGRect(x: 302, y: 234, width: 420, height: 590)
    let paperPath = roundedRectPath(paperRect, radius: 82)
    let paperGradient = NSGradient(colors: [palette.paperTop, palette.paperBottom])!
    paperGradient.draw(in: paperPath, angle: -90)

    NSGraphicsContext.current?.saveGraphicsState()
    paperPath.addClip()
    let foldPath = NSBezierPath()
    foldPath.move(to: CGPoint(x: 612, y: 824))
    foldPath.line(to: CGPoint(x: 642, y: 824))
    foldPath.curve(to: CGPoint(x: 722, y: 744), controlPoint1: CGPoint(x: 686, y: 824), controlPoint2: CGPoint(x: 722, y: 788))
    foldPath.line(to: CGPoint(x: 722, y: 714))
    foldPath.line(to: CGPoint(x: 692, y: 714))
    foldPath.curve(to: CGPoint(x: 612, y: 794), controlPoint1: CGPoint(x: 648, y: 714), controlPoint2: CGPoint(x: 612, y: 750))
    foldPath.close()
    palette.fold.setFill()
    foldPath.fill()
    NSGraphicsContext.current?.restoreGraphicsState()

    NSShadow().set()
    let lines: [(CGFloat, CGFloat, NSColor)] = [
        (344, 300, palette.primaryLine),
        (394, 244, palette.secondaryLine),
        (444, 266, palette.secondaryLine),
        (494, 220, palette.secondaryLine),
        (580, 120, palette.primaryLine),
        (580, 142, palette.primaryLine)
    ]

    for (y, width, color) in lines {
        color.setFill()
        roundedRectPath(CGRect(x: 362, y: y, width: width, height: 18), radius: 9).fill()
    }

    let scanRect = CGRect(x: 348, y: 390, width: 328, height: 94)
    let scanPath = roundedRectPath(scanRect, radius: 28)
    palette.scanStroke.setStroke()
    scanPath.lineWidth = 12
    let dashPattern: [CGFloat] = [22, 18]
    scanPath.setLineDash(dashPattern, count: dashPattern.count, phase: 0)
    scanPath.stroke()

    if palette.scanGlow.alphaComponent > 0 {
        let glowRect = CGRect(x: 338, y: 428, width: 348, height: 24)
        let glowPath = roundedRectPath(glowRect, radius: 12)
        let glowGradient = NSGradient(colors: [
            palette.scanGlow.withAlphaComponent(0.0),
            palette.scanGlow,
            palette.scanGlow.withAlphaComponent(0.0)
        ])!
        glowGradient.draw(in: glowPath, angle: 0)
    }

    let badgeRect = CGRect(x: 514, y: 244, width: 252, height: 252)
    palette.badge.setFill()
    NSBezierPath(ovalIn: badgeRect).fill()

    let checkPath = NSBezierPath()
    checkPath.move(to: CGPoint(x: 610, y: 370))
    checkPath.line(to: CGPoint(x: 635, y: 345))
    checkPath.line(to: CGPoint(x: 681, y: 393))
    palette.badgeCheck.setStroke()
    checkPath.lineWidth = 28
    checkPath.lineCapStyle = .round
    checkPath.lineJoinStyle = .round
    checkPath.stroke()

    image.unlockFocus()

    guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
    else {
        throw NSError(domain: "render_icons", code: 1)
    }

    try pngData.write(to: URL(fileURLWithPath: path))
}

for icon in icons {
    try drawIcon(palette: icon.palette, to: icon.path)
    print("Wrote \(icon.path)")
}
