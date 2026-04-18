import AppKit
import Combine
import Foundation
import UniformTypeIdentifiers

final class PlayerManager: ObservableObject {
    @Published var selectedFileURL: URL?

    func pickAudioFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.audio]
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }
}
