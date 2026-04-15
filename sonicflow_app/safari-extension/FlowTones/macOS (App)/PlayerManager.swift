import AppKit
import Combine
import Foundation

final class PlayerManager: ObservableObject {
    @Published var selectedFileURL: URL?

    func pickAudioFile() {
        let panel = NSOpenPanel()
        panel.allowedFileTypes = ["mp3", "wav", "aiff", "m4a", "aac", "flac"]
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK {
            selectedFileURL = panel.url
        }
    }
}
