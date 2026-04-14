import AVFoundation
import Foundation
import UIKit

final class PlayerManager: NSObject, ObservableObject {
    @Published var selectedFileURL: URL?
    let playerNode = AVAudioPlayerNode()

    func presentPicker() {
        // SF-9 will connect this to a SwiftUI document picker wrapper.
    }

    func loadFile(url: URL) {
        selectedFileURL = url
    }
}
