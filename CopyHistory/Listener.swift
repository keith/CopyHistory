import AppKit
import Foundation

final class Listener {
    private var timer: Timer?
    private var previousCount = 0

    private(set) var items = [PasteboardItem]()

    func start() {
        self.timer = Timer.scheduledTimer(
            timeInterval: 0.05,
            target: self,
            selector: #selector(self.fire),
            userInfo: nil,
            repeats: true
        )
    }

    @objc
    private func fire() {
        let pasteboard = NSPasteboard.general
        let newCount = pasteboard.changeCount
        if self.previousCount == newCount {
            return
        }

        self.previousCount = newCount
        let newItem = PasteboardItem(
            pasteboard: pasteboard,
            types: pasteboard.types ?? []
        )
        self.items.insert(newItem, at: 0)
        if self.items.count > 100 {
            self.items.removeLast()
        }
    }

    func paste(item: PasteboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        item.write(to: pasteboard)
        sendPaste()
    }

    func clearItems() {
        self.items = []
    }

    deinit {
        self.timer?.invalidate()
    }
}
