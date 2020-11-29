import AppKit
import Foundation

func requestAccessibilityIfNeeded() {
    let options: [NSString: Bool] = [
        kAXTrustedCheckOptionPrompt.takeUnretainedValue(): true
    ]

    if AXIsProcessTrustedWithOptions(options as CFDictionary) {
        return
    }

    let alert = NSAlert()
    alert.messageText = "Enable Accessibility First"
    alert.informativeText = "Find the system popup behind this one, click \"Open System Preferences\" and enable CopyHistory. Then launch CopyHistory again."
    alert.alertStyle = .critical
    alert.addButton(withTitle: "Quit")
    alert.runModal()
    NSApp.terminate(nil)
}
