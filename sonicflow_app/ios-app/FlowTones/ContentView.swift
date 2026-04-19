import SwiftUI
import FlowTonesCore

struct ContentView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var playerManager: PlayerManager
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: BrandTokens.Spacing.md),
        count: 2
    )

    var body: some View {
        ZStack {
            BrandTokens.Neutral.bg
                .ignoresSafeArea()

            LeopardBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.lg) {
                    header

                    LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.md) {
                        ForEach(FlowMode.allCases, id: \.self) { mode in
                            ModeCard(
                                mode: mode,
                                isSelected: mode == audioManager.currentMode
                            ) {
                                audioManager.currentMode = mode
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                        Text("Neural layer")
                            .font(.headline)
                            .foregroundStyle(BrandTokens.Neutral.fg)
                        Slider(value: $audioManager.beatVolume, in: 0...1)
                            .tint(audioManager.currentMode.accentColor)
                    }

                    VisualizerView(
                        isPlaying: audioManager.isPlaying,
                        mode: audioManager.currentMode
                    )

                    HStack(spacing: BrandTokens.Spacing.md) {
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
                            .foregroundStyle(BrandTokens.Neutral.muted)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding(BrandTokens.Spacing.lg)
            }
        }
    }

    private var header: some View {
        HStack {
            Text("SonicFlow")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(BrandTokens.Neutral.fg)
            Spacer()
            HStack(spacing: BrandTokens.Spacing.sm) {
                Circle()
                    .fill(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
                    .frame(width: 10, height: 10)
                Text(audioManager.isPlaying ? "Active" : "Off")
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(BrandTokens.Neutral.muted)
            }
            .padding(.horizontal, BrandTokens.Spacing.md)
            .padding(.vertical, BrandTokens.Spacing.sm)
            .background(BrandTokens.Neutral.panel, in: Capsule())
        }
    }
}
