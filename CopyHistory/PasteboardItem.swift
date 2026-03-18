import AppKit
import Foundation

private extension NSPasteboard.PasteboardType {
    static let fileURLs = NSPasteboard.PasteboardType("NSFilenamesPboardType")
}

final class PasteboardItem: CustomDebugStringConvertible, MenuItem {
    var string: String?
    var URL: String?
    var fileURL: String?
    var rtf: String?
    var fileURLs: [String]?
    var tiff: Data?
    var png: Data?

    init(pasteboard: NSPasteboard, types: [NSPasteboard.PasteboardType]) {
        for type in types {
            switch type {
            case .string:
                self.string = pasteboard.string(forType: .string)
            case .URL:
                self.URL = pasteboard.string(forType: .URL)
            case .fileURL:
                self.fileURL = pasteboard.string(forType: .fileURL)
            case .rtf:
                self.rtf = pasteboard.string(forType: .rtf)
            case .fileURLs:
                self.fileURLs = pasteboard.propertyList(forType: .fileURLs) as? [String]
            case .tiff:
                self.tiff = pasteboard.data(forType: .tiff)
            case .png:
                self.png = pasteboard.data(forType: .png)
            default:
                break
            }
        }
    }

    func write(to pasteboard: NSPasteboard) {
        if let string = self.string {
            pasteboard.setString(string, forType: .string)
        }

        if let URL = self.URL {
            pasteboard.setString(URL, forType: .URL)
        }

        if let fileURL = self.fileURL {
            pasteboard.setString(fileURL, forType: .fileURL)
        }

        if let rtf = self.rtf {
            pasteboard.setString(rtf, forType: .rtf)
        }

        if let fileURLs = self.fileURLs {
            pasteboard.setPropertyList(fileURLs, forType: .fileURLs)
        }

        if let tiff = self.tiff {
            pasteboard.setData(tiff, forType: .tiff)
        }

        if let png = self.png {
            pasteboard.setData(png, forType: .png)
        }
    }

    var image: NSImage? {
        guard let data = self.tiff ?? self.png,
              let full = NSImage(data: data) else {
            return nil
        }
        let maxSize: CGFloat = 32
        let originalSize = full.size
        if originalSize.width == 0 || originalSize.height == 0 {
            return nil
        }
        let scale = min(maxSize / originalSize.width, maxSize / originalSize.height, 1)
        let newSize = NSSize(
            width: originalSize.width * scale,
            height: originalSize.height * scale
        )
        let thumbnail = NSImage(size: newSize)
        thumbnail.lockFocus()
        full.draw(in: NSRect(origin: .zero, size: newSize))
        thumbnail.unlockFocus()
        return thumbnail
    }

    var title: String {
        if let value = self.string {
            if value.count > 200 {
                return String(value.prefix(200)) + "…"
            }
            return value
        }
        if self.tiff != nil || self.png != nil {
            return ""
        }
        return "<unknown>"
    }

    var debugDescription: String {
        return """
Pasteboard item contents:

string: '\(self.string ?? "<none>")'
URL: '\(self.URL ?? "<none>")'
rtf length: '\(self.rtf?.count ?? 0)'
fileURL: '\(self.fileURL ?? "<none>")'
fileURLs: '\(self.fileURLs ?? [])'

"""
    }
}
