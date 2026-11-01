//
//  GenerateAppIcon.swift
//  Pipeline
//
//  Renders the light, dark, and tinted 1024×1024 app icons.
//
//  Usage:
//    swift Scripts/GenerateAppIcon.swift \
//      pipeline/Resources/Assets.xcassets/AppIcon.appiconset
//

import AppKit
import CoreGraphics

let size = 1024
let outputDirectory = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "."

func color(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
    let red = CGFloat((hex >> 16) & 0xFF) / 255
    let green = CGFloat((hex >> 8) & 0xFF) / 255
    let blue = CGFloat(hex & 0xFF) / 255
    return CGColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
}

func makeContext(alpha: Bool) -> CGContext {
    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
    let bitmapInfo = alpha
        ? CGImageAlphaInfo.premultipliedLast.rawValue
        : CGImageAlphaInfo.noneSkipLast.rawValue
    let context = CGContext(
        data: nil,
        width: size,
        height: size,
        bitsPerComponent: 8,
        bytesPerRow: 0,
        space: colorSpace,
        bitmapInfo: bitmapInfo
    )!
    context.translateBy(x: 0, y: CGFloat(size))
    context.scaleBy(x: 1, y: -1)
    context.setAllowsAntialiasing(true)
    context.setShouldAntialias(true)
    return context
}

func drawGradient(
    _ context: CGContext,
    colors: [CGColor],
    locations: [CGFloat],
    start: CGPoint,
    end: CGPoint
) {
    let gradient = CGGradient(
        colorsSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        colors: colors as CFArray,
        locations: locations
    )!
    context.drawLinearGradient(
        gradient,
        start: start,
        end: end,
        options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
    )
}

func drawRadialGlow(
    _ context: CGContext,
    center: CGPoint,
    radius: CGFloat,
    color glowColor: CGColor
) {
    let gradient = CGGradient(
        colorsSpace: CGColorSpace(name: CGColorSpace.sRGB)!,
        colors: [glowColor, color(0x000000, alpha: 0)] as CFArray,
        locations: [0, 1]
    )!
    context.drawRadialGradient(
        gradient,
        startCenter: center,
        startRadius: 0,
        endCenter: center,
        endRadius: radius,
        options: [.drawsAfterEndLocation]
    )
}

func circlePath(center: CGPoint, radius: CGFloat) -> CGPath {
    CGPath(ellipseIn: CGRect(
        x: center.x - radius,
        y: center.y - radius,
        width: radius * 2,
        height: radius * 2
    ), transform: nil)
}

func drawGlowLine(_ context: CGContext, path: CGPath, width: CGFloat, glow: CGColor) {
    context.saveGState()
    context.addPath(path)
    context.setLineWidth(width)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.setStrokeColor(glow)
    context.strokePath()
    context.restoreGState()
}

func drawGradientLine(
    _ context: CGContext,
    path: CGPath,
    width: CGFloat,
    colors: [CGColor],
    start: CGPoint,
    end: CGPoint
) {
    context.saveGState()
    context.addPath(path)
    context.setLineWidth(width)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.replacePathWithStrokedPath()
    context.clip()
    drawGradient(context, colors: colors, locations: [0, 1], start: start, end: end)
    context.restoreGState()
}

func drawNode(
    _ context: CGContext,
    center: CGPoint,
    radius: CGFloat,
    fill: [CGColor],
    stroke: CGColor? = nil,
    strokeWidth: CGFloat = 0
) {
    let path = circlePath(center: center, radius: radius)
    context.saveGState()
    context.addPath(path)
    context.clip()
    drawGradient(
        context,
        colors: fill,
        locations: [0, 1],
        start: CGPoint(x: center.x - radius, y: center.y - radius),
        end: CGPoint(x: center.x + radius, y: center.y + radius)
    )
    context.restoreGState()

    if let stroke, strokeWidth > 0 {
        context.saveGState()
        context.addPath(path)
        context.setStrokeColor(stroke)
        context.setLineWidth(strokeWidth)
        context.strokePath()
        context.restoreGState()
    }
}

func drawCheck(_ context: CGContext, center: CGPoint, scale: CGFloat, color checkColor: CGColor, width: CGFloat) {
    let check = CGMutablePath()
    check.move(to: CGPoint(x: center.x - 70 * scale, y: center.y + 5 * scale))
    check.addLine(to: CGPoint(x: center.x - 18 * scale, y: center.y + 57 * scale))
    check.addLine(to: CGPoint(x: center.x + 82 * scale, y: center.y - 55 * scale))

    context.saveGState()
    context.setShadow(
        offset: CGSize(width: 0, height: 8 * scale),
        blur: 24 * scale,
        color: color(0x052E1B, alpha: 0.35)
    )
    context.addPath(check)
    context.setStrokeColor(checkColor)
    context.setLineWidth(width * scale)
    context.setLineCap(.round)
    context.setLineJoin(.round)
    context.strokePath()
    context.restoreGState()
}

func drawMotif(
    _ context: CGContext,
    primaryStart: CGColor,
    primaryEnd: CGColor,
    nodeOneFill: [CGColor],
    nodeTwoFill: [CGColor],
    nodeOneStroke: CGColor,
    nodeTwoStroke: CGColor,
    finalFill: [CGColor],
    checkColor: CGColor,
    glow: CGColor,
    lineGlow: CGColor,
    backgroundGlow: CGColor
) {
    let first = CGPoint(x: 268, y: 752)
    let second = CGPoint(x: 482, y: 570)
    let third = CGPoint(x: 694, y: 338)

    let route = CGMutablePath()
    route.move(to: first)
    route.addLine(to: second)
    route.addLine(to: third)

    drawRadialGlow(
        context,
        center: CGPoint(x: third.x + 24, y: third.y - 18),
        radius: 330,
        color: backgroundGlow
    )

    drawGlowLine(context, path: route, width: 104, glow: lineGlow)
    drawGradientLine(
        context,
        path: route,
        width: 58,
        colors: [primaryStart, primaryEnd],
        start: first,
        end: third
    )

    drawNode(
        context,
        center: first,
        radius: 60,
        fill: nodeOneFill,
        stroke: nodeOneStroke,
        strokeWidth: 14
    )
    drawNode(
        context,
        center: second,
        radius: 74,
        fill: nodeTwoFill,
        stroke: nodeTwoStroke,
        strokeWidth: 16
    )

    context.saveGState()
    context.setShadow(offset: CGSize(width: 0, height: 14), blur: 40, color: glow)
    drawNode(
        context,
        center: third,
        radius: 152,
        fill: finalFill
    )
    context.restoreGState()

    drawCheck(context, center: third, scale: 1.0, color: checkColor, width: 42)
}

func renderDefault(dark: Bool) -> CGImage {
    let context = makeContext(alpha: dark)

    if dark {
        context.clear(CGRect(x: 0, y: 0, width: size, height: size))
    } else {
        drawGradient(
            context,
            colors: [color(0x0A1226), color(0x15305B)],
            locations: [0, 1],
            start: CGPoint(x: 120, y: 40),
            end: CGPoint(x: 920, y: 1000)
        )

        drawRadialGlow(
            context,
            center: CGPoint(x: 850, y: 180),
            radius: 620,
            color: color(0x2563EB, alpha: 0.22)
        )
        drawRadialGlow(
            context,
            center: CGPoint(x: 80, y: 980),
            radius: 520,
            color: color(0x06B6D4, alpha: 0.12)
        )
    }

    drawMotif(
        context,
        primaryStart: dark ? color(0x7DD3FC) : color(0x60A5FA),
        primaryEnd: dark ? color(0x5EEAD4) : color(0x2DD4BF),
        nodeOneFill: dark
            ? [color(0x1D4ED8), color(0x172554)]
            : [color(0x1E3A8A), color(0x0F1F45)],
        nodeTwoFill: dark
            ? [color(0x0E7490), color(0x083344)]
            : [color(0x155E75), color(0x0B2E44)],
        nodeOneStroke: color(0x7DD3FC, alpha: 0.95),
        nodeTwoStroke: color(0x67E8F9, alpha: 0.95),
        finalFill: dark
            ? [color(0x6EE7B7), color(0x059669)]
            : [color(0x6EE7B7), color(0x10B981)],
        checkColor: color(0xFFFFFF),
        glow: color(0x10B981, alpha: dark ? 0.35 : 0.45),
        lineGlow: color(0x38BDF8, alpha: dark ? 0.16 : 0.12),
        backgroundGlow: color(0x2DD4BF, alpha: dark ? 0.0 : 0.16)
    )

    return context.makeImage()!
}

func renderTinted() -> CGImage {
    let context = makeContext(alpha: false)

    drawGradient(
        context,
        colors: [color(0x121212), color(0x303030)],
        locations: [0, 1],
        start: CGPoint(x: 120, y: 40),
        end: CGPoint(x: 920, y: 1000)
    )
    drawRadialGlow(
        context,
        center: CGPoint(x: 694, y: 338),
        radius: 430,
        color: color(0xFFFFFF, alpha: 0.10)
    )

    drawMotif(
        context,
        primaryStart: color(0xD4D4D4),
        primaryEnd: color(0xF5F5F5),
        nodeOneFill: [color(0x9CA3AF), color(0x6B7280)],
        nodeTwoFill: [color(0xB0B0B0), color(0x8A8A8A)],
        nodeOneStroke: color(0xE5E5E5),
        nodeTwoStroke: color(0xF0F0F0),
        finalFill: [color(0xFFFFFF), color(0xD4D4D4)],
        checkColor: color(0x111111),
        glow: color(0x000000, alpha: 0.35),
        lineGlow: color(0xFFFFFF, alpha: 0.10),
        backgroundGlow: color(0xFFFFFF, alpha: 0.0)
    )

    return context.makeImage()!
}

func writePNG(_ image: CGImage, named name: String) throws {
    let representation = NSBitmapImageRep(cgImage: image)
    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw NSError(domain: "Icon", code: 1, userInfo: [NSLocalizedDescriptionKey: "PNG encoding failed"])
    }
    let url = URL(fileURLWithPath: outputDirectory).appendingPathComponent(name)
    try data.write(to: url)
    print(url.path)
}

try writePNG(renderDefault(dark: false), named: "AppIcon.png")
try writePNG(renderDefault(dark: true), named: "AppIcon-Dark.png")
try writePNG(renderTinted(), named: "AppIcon-Tinted.png")
