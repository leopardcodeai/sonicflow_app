import SwiftUI

struct FlowTonesPopoverView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var playerManager: PlayerManager

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

    var body: some View {
        ZStack {
            Color(hex: "#121212")
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 12) {
                Text("FlowTones")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(FlowMode.allCases, id: \.self) { mode in
                        ModeCard(mode: mode, isSelected: mode == audioManager.currentMode) {
                            audioManager.currentMode = mode
                        }
                    }
                }

                Picker("Source", selection: $audioManager.selectedSource) {
                    Text("System audio").tag(AudioSource.system)
                    Text("File").tag(AudioSource.file)
                }
                .pickerStyle(.segmented)

                sourceSection

                VStack(alignment: .leading, spacing: 6) {
                    Text("Beat volume")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Slider(value: $audioManager.beatVolume, in: 0...1)
                        .tint(audioManager.currentMode.accentColor)
                }

                HStack(spacing: 8) {
                    Image(systemName: "waveform")
                        .foregroundStyle(audioManager.isPlaying ? .green : .secondary)
                    Text(audioManager.statusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button(audioManager.isPlaying ? "Pause" : "Start") {
                    audioManager.togglePlayback()
                }
                .buttonStyle(.borderedProminent)
                .tint(audioManager.currentMode.accentColor)
            }
            .padding(12)
        }
        .frame(width: 300, height: 400)
    }

    @ViewBuilder
    private var sourceSection: some View {
        switch audioManager.selectedSource {
        case .system:
            VStack(alignment: .leading, spacing: 8) {
                Text("Permission: \(audioManager.systemAudioPermissionStatus)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Start Capture") {
                    audioManager.startSystemAudioCapture()
                }
                .buttonStyle(.bordered)
            }
        case .file:
            VStack(alignment: .leading, spacing: 8) {
                Button(playerManager.selectedFileURL == nil ? "Pick File" : "Replace File") {
                    playerManager.pickAudioFile()
                }
                .buttonStyle(.bordered)

                if let selectedFileURL = playerManager.selectedFileURL {
                    Text(selectedFileURL.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}
