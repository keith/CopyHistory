import AppKit
import Foundation

private class MenuDelegate: NSObject, NSMenuDelegate {
    private let didClose: () -> Void

    init(didClose: @escaping () -> Void) {
        self.didClose = didClose
        super.init()
    }

    func menuDidClose(_ menu: NSMenu) {
        self.didClose()
    }
}

private extension Array {
    func bucket(size: Int) -> [[Element]] {
        var array = self
        var buckets = [[Element]]()
        while array.count > 0 {
            buckets.append(Array(array.prefix(count)))
            array.removeFirst(Swift.min(size, array.count))
        }

        return buckets
    }
}

final class Menu<T: MenuItem> {
    private let items: [T]
    private let itemHit: (T) -> Void
    private let clear: () -> Void
    private let menuDelegate: MenuDelegate
    private var menu: NSMenu?

    init(items: [T],
         itemHit: @escaping (T) -> Void,
         clear: @escaping () -> Void,
         didClose: @escaping () -> Void)
    {
        self.items = items
        self.itemHit = itemHit
        self.clear = clear
        self.menuDelegate = MenuDelegate(didClose: didClose)
    }

    func show() {
        var items = self.items
		let menu = NSMenu()
        menu.delegate = self.menuDelegate

        var initialIndex = 9
        let initialItems = Array(items.prefix(9))
        items.removeFirst(min(items.count, 9))
        for (index, item) in initialItems.enumerated() {
            menu.addItem(self.menuItem(for: item, index: index + 1))
        }

        initialIndex += 1
        let buckets = items.bucket(size: 10)
        for bucket in buckets {
            let bucketTitle = "\(initialIndex) - \(initialIndex + 10)"
            let submenuItem = NSMenuItem()
            submenuItem.title = bucketTitle
            let submenu = NSMenu()
            menu.addItem(submenuItem)
            menu.setSubmenu(submenu, for: submenuItem)

            for item in bucket {
                submenu.addItem(self.menuItem(for: item, index: 0))
            }
        }

        menu.addItem(NSMenuItem.separator())
        let clearItem = menu.addItem(
            withTitle: "Clear History",
            action: #selector(Menu.clearHistory),
            keyEquivalent: ""
        )
        clearItem.target = self
        // TODO: This does nothing, not a big deal
        clearItem.isEnabled = self.items.count > 0
        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
        self.menu = menu
    }

    private func menuItem(for item: T, index: Int) -> NSMenuItem {
        let keyEquivalent = index > 0 && index < 10 ? "\(index)" : ""
        let menuItem = NSMenuItem()
        menuItem.action = #selector(Menu.selected(_:))
        menuItem.keyEquivalent = keyEquivalent
        menuItem.title = item.title
        menuItem.target = self
        menuItem.representedObject = item
        return menuItem
    }

    @objc
    private func selected(_ sender: NSMenuItem) {
        self.itemHit(sender.representedObject as! T)
    }

    @objc
    private func clearHistory() {
        self.clear()
    }
}
