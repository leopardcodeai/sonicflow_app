import AppKit

final class MacMenuCommands {
    private var globalMonitor: Any?
    private var localMonitor: Any?

    func startMonitoring(onToggle: @escaping () -> Void) {
        stopMonitoring()

        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard self?.isToggleShortcut(event) == true else {
                return
            }
            onToggle()
        }

        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard self?.isToggleShortcut(event) == true else {
                return event
            }
            onToggle()
            return nil
        }
    }

    func stopMonitoring() {
        if let globalMonitor {
            NSEvent.removeMonitor(globalMonitor)
            self.globalMonitor = nil
        }
        if let localMonitor {
            NSEvent.removeMonitor(localMonitor)
            self.localMonitor = nil
        }
    }

    private func isToggleShortcut(_ event: NSEvent) -> Bool {
        let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard modifiers == [.command, .shift] else {
            return false
        }

        return event.charactersIgnoringModifiers?.lowercased() == "f"
    }
}
