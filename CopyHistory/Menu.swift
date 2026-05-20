import AppKit
import Foundation

private let inlineSize = 9
private let bucketSize = 10

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
        while !array.isEmpty {
            let bucketCount = Swift.min(10, array.count)
            buckets.append(Array(array[0..<bucketCount]))
            array.removeFirst(bucketCount)
        }

        return buckets
    }
}

private final class SearchFieldView: NSView, NSSearchFieldDelegate {
    let searchField = NSSearchField()
    var onChange: ((String) -> Void)?
    var onEnter: (() -> Void)?

    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 300, height: 30))
        self.searchField.frame = NSRect(x: 14, y: 4, width: 272, height: 22)
        self.searchField.autoresizingMask = [.width]
        self.searchField.sendsWholeSearchString = true
        self.searchField.sendsSearchStringImmediately = false
        self.searchField.target = self
        self.searchField.action = #selector(submit(_:))
        self.searchField.delegate = self
        self.searchField.placeholderString = "Search"
        self.addSubview(self.searchField)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func submit(_ sender: Any?) {
        self.onEnter?()
    }

    func controlTextDidChange(_ notification: Notification) {
        self.onChange?(self.searchField.stringValue)
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard self.window != nil else { return }
        RunLoop.main.perform(inModes: [.eventTracking, .common, .default]) { [weak self] in
            guard let self = self, let window = self.window else { return }
            window.makeFirstResponder(self.searchField)
        }
    }
}

final class Menu<T: MenuItem> {
    private let items: [T]
    private let itemHit: (T) -> Void
    private let clear: () -> Void
    private let menuDelegate: MenuDelegate
    private var menu: NSMenu?
    private var dynamicRangeStart = 0
    private var dynamicRangeCount = 0
    private var currentMatches: [T] = []

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
		let menu = NSMenu()
        menu.autoenablesItems = false
        menu.delegate = self.menuDelegate

        let searchItem = NSMenuItem()
        let searchView = SearchFieldView()
        searchView.onChange = { [weak self] query in
            self?.applyFilter(query: query)
        }
        searchView.onEnter = { [weak self] in
            self?.handleEnter()
        }
        searchItem.view = searchView
        menu.addItem(searchItem)
        menu.addItem(NSMenuItem.separator())

        self.dynamicRangeStart = menu.items.count
        self.populateDefaultItems(in: menu)
        self.dynamicRangeCount = menu.items.count - self.dynamicRangeStart

        menu.addItem(NSMenuItem.separator())
        let clearItem = menu.addItem(
            withTitle: "Clear History",
            action: #selector(Menu.clearHistory),
            keyEquivalent: ""
        )
        clearItem.target = self
        // TODO: This does nothing, not a big deal
        clearItem.isEnabled = self.items.count > 0

        let quitItem = menu.addItem(
            withTitle: "Quit",
            action: #selector(NSApp.terminate(_:)),
            keyEquivalent: ""
        )
        quitItem.target = NSApp

        self.menu = menu
        menu.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    private func populateDefaultItems(in menu: NSMenu) {
        var items = self.items
        var initialIndex = 9
        let initialItems = Array(items.prefix(inlineSize))
        items.removeFirst(min(items.count, inlineSize))
        for (index, item) in initialItems.enumerated() {
            menu.addItem(self.menuItem(for: item, index: index + 1))
        }

        initialIndex += 1
        let buckets = items.bucket(size: bucketSize)
        for bucket in buckets {
            let bucketTitle = "\(initialIndex) - \(initialIndex + bucketSize)"
            initialIndex += bucketSize
            let submenuItem = NSMenuItem()
            submenuItem.title = bucketTitle
            let submenu = NSMenu()
            menu.addItem(submenuItem)
            menu.setSubmenu(submenu, for: submenuItem)

            for item in bucket {
                submenu.addItem(self.menuItem(for: item, index: 0))
            }
        }
    }

    private func applyFilter(query: String) {
        guard let menu = self.menu else { return }
        let start = self.dynamicRangeStart
        for _ in 0..<self.dynamicRangeCount {
            menu.removeItem(at: start)
        }

        let trimmed = query.trimmingCharacters(in: .whitespaces)
        var inserted = 0
        if trimmed.isEmpty {
            self.currentMatches = []
            let temp = NSMenu()
            self.populateDefaultItems(in: temp)
            while !temp.items.isEmpty {
                let item = temp.items[0]
                temp.removeItem(at: 0)
                menu.insertItem(item, at: start + inserted)
                inserted += 1
            }
        } else {
            let matches = self.items.filter { item in
                item.title.range(of: trimmed, options: .caseInsensitive) != nil
            }
            self.currentMatches = matches
            if matches.isEmpty {
                let none = NSMenuItem()
                none.title = "No matches"
                none.isEnabled = false
                menu.insertItem(none, at: start + inserted)
                inserted += 1
            } else {
                for item in matches {
                    let mi = self.menuItem(for: item, index: 0)
                    menu.insertItem(mi, at: start + inserted)
                    inserted += 1
                }
            }
        }
        self.dynamicRangeCount = inserted
    }

    private func handleEnter() {
        guard let first = self.currentMatches.first else { return }
        self.menu?.cancelTracking()
        self.itemHit(first)
    }

    private func menuItem(for item: T, index: Int) -> NSMenuItem {
        let keyEquivalent = index > 0 && index < 10 ? "\(index)" : ""
        let menuItem = NSMenuItem()
        menuItem.action = #selector(Menu.selected(_:))
        menuItem.keyEquivalent = keyEquivalent
        menuItem.title = item.title
        menuItem.image = item.image
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
