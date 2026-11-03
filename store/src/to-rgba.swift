// Re-encodes a PNG as 32-bit RGBA, which Play requires for the app icon.
// Usage: swift store/src/to-rgba.swift <in.png> <out.png>
import AppKit

let args = CommandLine.arguments
guard args.count == 3, let image = NSImage(contentsOfFile: args[1]),
      let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
  FileHandle.standardError.write("usage: to-rgba <in.png> <out.png>\n".data(using: .utf8)!)
  exit(1)
}
let ctx = CGContext(data: nil, width: cg.width, height: cg.height, bitsPerComponent: 8,
                    bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
let rep = NSBitmapImageRep(cgImage: ctx.makeImage()!)
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: args[2]))
