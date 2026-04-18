import SwiftUI
import FlowTonesCore

struct ContentView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var playerManager: PlayerManager
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        ZStack {
            Color(hex: "#0f0f0f")
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(FlowMode.allCases, id: \.self) { mode in
                            ModeCard(
                                mode: mode,
                                isSelected: mode == audioManager.currentMode
                            ) {
                                audioManager.currentMode = mode
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Neural layer")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Slider(value: $audioManager.beatVolume, in: 0...1)
                            .tint(audioManager.currentMode.accentColor)
                    }

                    VisualizerView(
                        isPlaying: audioManager.isPlaying,
                        mode: audioManager.currentMode
                    )

                    HStack(spacing: 12) {
                        Button(audioManager.isPlaying ? "Pause" : "Play") {
                            audioManager.togglePlayback()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(audioManager.currentMode.accentColor)

                        FilePickerButton(playerManager: playerManager)
                    }

                    if let selectedFileURL = playerManager.selectedFileURL {
                        Text(selectedFileURL.lastPathComponent)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(20)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("SonicFlow")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
            Spacer()
            HStack(spacing: 8) {
                Circle()
                    .fill(audioManager.isPlaying ? .green : .gray)
                    .frame(width: 10, height: 10)
                Text(audioManager.isPlaying ? "Active" : "Off")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08), in: Capsule())
        }
    }
}
