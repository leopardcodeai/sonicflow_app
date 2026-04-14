import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct FilePickerButton: View {
    @ObservedObject var playerManager: PlayerManager
    @State private var isPresentingPicker = false

    var body: some View {
        Button(playerManager.selectedFileURL == nil ? "Pick File" : "Replace File") {
            isPresentingPicker = true
        }
        .buttonStyle(.bordered)
        .sheet(isPresented: $isPresentingPicker) {
            AudioDocumentPicker { url in
                playerManager.loadFile(url: url)
            }
        }
    }
}

private struct AudioDocumentPicker: UIViewControllerRepresentable {
    let onPick: (URL) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.audio, .mp3, .wav, .aiff],
            asCopy: false
        )
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void

        init(onPick: @escaping (URL) -> Void) {
            self.onPick = onPick
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else {
                return
            }
            onPick(url)
        }
    }
}
