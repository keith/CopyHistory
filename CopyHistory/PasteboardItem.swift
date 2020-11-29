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
    }

    var title: String {
        // TODO: This really should be non-optional, not sure how
        self.string ?? "<unknown>"
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
