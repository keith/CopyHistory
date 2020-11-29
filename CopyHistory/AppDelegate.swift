import Cocoa
import SwiftUI

@main
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let listener = Listener()
    private var window: NSWindow!
    private var menu: Menu<PasteboardItem>?

    private func showMenu() {
        let menu = Menu(items: self.listener.items, itemHit: { [weak self] item in
            self?.listener.paste(item: item)
        }, clear: { [weak self] in
            self?.listener.clearItems()
        }, didClose: { [weak self] in
            self?.menu = nil
        })

        menu.show()
        self.menu = menu
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        foo()
        self.listener.start()

        HotKey.withKey("v", mods: ["CTRL", "CMD"]) { [weak self] in
            self?.showMenu()
            return true
        }?.enable()
    }
}
