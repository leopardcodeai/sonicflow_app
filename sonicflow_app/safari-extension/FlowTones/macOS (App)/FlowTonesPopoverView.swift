import SwiftUI

struct FlowTonesPopoverView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var playerManager: PlayerManager

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: BrandTokens.Spacing.sm),
        count: 2
    )

    var body: some View {
        ZStack {
            BrandTokens.Neutral.bg
                .ignoresSafeArea()

            LeopardBackgroundView()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
                Text("SonicFlow")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(BrandTokens.Neutral.fg)

                LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.sm) {
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

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
                    Text("Beat volume")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BrandTokens.Neutral.muted)
                    Slider(value: $audioManager.beatVolume, in: 0...1)
                        .tint(audioManager.currentMode.accentColor)
                }

                HStack(spacing: BrandTokens.Spacing.sm) {
                    Image(systemName: "waveform")
                        .foregroundStyle(
                            audioManager.isPlaying
                                ? BrandTokens.Accent.success
                                : BrandTokens.Neutral.muted
                        )
                    Text(audioManager.statusText)
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                }

                Button(audioManager.isPlaying ? "Pause" : "Start") {
                    audioManager.togglePlayback()
                }
                .buttonStyle(.borderedProminent)
                .tint(audioManager.currentMode.accentColor)
            }
            .padding(BrandTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: BrandTokens.Radius.lg)
                    .fill(BrandTokens.Neutral.panel)
                    .overlay(
                        RoundedRectangle(cornerRadius: BrandTokens.Radius.lg)
                            .stroke(BrandTokens.Neutral.border, lineWidth: 1)
                    )
            )
            .padding(BrandTokens.Spacing.sm)
        }
        .frame(width: 300, height: 400)
    }

    @ViewBuilder
    private var sourceSection: some View {
        switch audioManager.selectedSource {
        case .system:
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                Text(audioManager.canCaptureSystemAudio ? "System capture verfügbar" : "System capture erst ab macOS 14.2")
                    .font(.caption2)
                    .foregroundStyle(
                        audioManager.canCaptureSystemAudio
                            ? BrandTokens.Neutral.muted
                            : BrandTokens.Chakra.sacral
                    )
                Text("Permission: \(audioManager.systemAudioPermissionStatus)")
                    .font(.caption)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Button("Start Capture") {
                    audioManager.startSystemAudioCapture()
                }
                .buttonStyle(.bordered)
                .disabled(!audioManager.canCaptureSystemAudio)
            }
        case .file:
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                Button(playerManager.selectedFileURL == nil ? "Pick File" : "Replace File") {
                    playerManager.pickAudioFile()
                }
                .buttonStyle(.bordered)

                if let selectedFileURL = playerManager.selectedFileURL {
                    Text(selectedFileURL.lastPathComponent)
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
        }
    }
}
