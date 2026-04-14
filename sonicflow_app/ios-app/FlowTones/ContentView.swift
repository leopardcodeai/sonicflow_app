import SwiftUI
import FlowTonesCore

struct ContentView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var playerManager: PlayerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("FlowTones")
                .font(.largeTitle.weight(.semibold))

            Text(audioManager.isPlaying ? "Active" : "Stopped")
                .foregroundStyle(audioManager.isPlaying ? .green : .secondary)

            Picker("Mode", selection: $audioManager.currentMode) {
                ForEach(FlowMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text("Neural layer")
                Slider(value: $audioManager.beatVolume, in: 0...1)
            }

            Button(audioManager.isPlaying ? "Pause" : "Play") {
                audioManager.isPlaying.toggle()
            }
            .buttonStyle(.borderedProminent)

            Button(playerManager.selectedFileURL == nil ? "Choose Audio File" : "Replace Audio File") {
                playerManager.presentPicker()
            }
            .buttonStyle(.bordered)

            if let selectedFileURL = playerManager.selectedFileURL {
                Text(selectedFileURL.lastPathComponent)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
    }
}
