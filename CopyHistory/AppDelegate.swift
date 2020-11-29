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
        self.listener.start()

        let contentView = ContentView { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {

            }
        }

        HotKey.withKey("c", mods: ["CTRL", "CMD"]) { [weak self] in
            self?.showMenu()
            return true
        }?.enable()

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }
}
