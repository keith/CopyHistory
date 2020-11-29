import Carbon

// https://stackoverflow.com/questions/19755942/how-to-paste-programmatically-on-os-x
func sendPaste() {
    let source = CGEventSource(stateID: .combinedSessionState)
    let pasteDownEvent = CGEvent(
        keyboardEventSource: source,
        virtualKey: UInt16(kVK_ANSI_V),
        keyDown: true
    )
    pasteDownEvent?.flags = .maskCommand

    let pasteUpEvent = CGEvent(
        keyboardEventSource: source,
        virtualKey: UInt16(kVK_ANSI_V),
        keyDown: false
    )
    pasteUpEvent?.flags = .maskCommand

    pasteDownEvent?.post(tap: .cgAnnotatedSessionEventTap)
    pasteUpEvent?.post(tap: .cgAnnotatedSessionEventTap)
}
