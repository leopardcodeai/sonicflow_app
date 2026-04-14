import AVFoundation
import Foundation

final class PlayerManager: NSObject, ObservableObject {
    @Published var selectedFileURL: URL?
    let playerNode = AVAudioPlayerNode()

    func loadFile(url: URL) {
        selectedFileURL = url
    }
}
