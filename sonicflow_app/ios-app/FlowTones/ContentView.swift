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
        let screenState = FlowScreenState(
            isPlaying: audioManager.isPlaying,
            mode: audioManager.currentMode,
            settings: audioManager.sessionSettings,
            selectedFileName: playerManager.selectedFileURL?.lastPathComponent
        )

        ZStack {
            BrandTokens.Neutral.bg
                .ignoresSafeArea()

            LeopardBackgroundView()
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.lg) {
                    header(for: screenState)
                    starterPack

                    LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.md) {
                        ForEach(FlowMode.allCases, id: \.self) { mode in
                            ModeCard(
                                mode: mode,
                                isSelected: mode == screenState.selectedMode
                            ) {
                                audioManager.currentMode = mode
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                        Text("Session")
                            .font(.headline)
                            .foregroundStyle(BrandTokens.Neutral.fg)

                        HStack {
                            Text("Duration")
                                .foregroundStyle(BrandTokens.Neutral.muted)
                            Spacer()
                            Stepper(
                                screenState.durationLabel,
                                value: Binding(
                                    get: { audioManager.sessionSettings.durationMinutes },
                                    set: audioManager.updateDuration
                                ),
                                in: 5...60,
                                step: 5
                            )
                            .tint(screenState.selectedMode.accentColor)
                        }
                    }
                    .padding(BrandTokens.Spacing.md)
                    .background(BrandTokens.Neutral.panel.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))

                    VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                        Text("Neural layer")
                            .font(.headline)
                            .foregroundStyle(BrandTokens.Neutral.fg)
                        Slider(value: $audioManager.beatVolume, in: 0...1)
                            .tint(screenState.selectedMode.accentColor)
                    }

                    if screenState.showsAdvancedControls {
                        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                            Text("Atmosphere")
                                .font(.headline)
                                .foregroundStyle(BrandTokens.Neutral.fg)

                            Text("Ambient mix")
                                .foregroundStyle(BrandTokens.Neutral.muted)
                            Slider(
                                value: Binding(
                                    get: { audioManager.sessionSettings.ambientMix },
                                    set: audioManager.updateAmbientMix
                                ),
                                in: 0.2...1
                            )
                            .tint(screenState.selectedMode.accentColor)

                            Text("Pulse depth")
                                .foregroundStyle(BrandTokens.Neutral.muted)
                            Slider(
                                value: Binding(
                                    get: { audioManager.sessionSettings.pulseDepth },
                                    set: audioManager.updatePulseDepth
                                ),
                                in: 0.2...1
                            )
                            .tint(screenState.selectedMode.accentColor)
                        }
                        .padding(BrandTokens.Spacing.md)
                        .background(BrandTokens.Neutral.panel.opacity(0.9), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    VisualizerView(
                        isPlaying: audioManager.isPlaying,
                        mode: screenState.selectedMode
                    )

                    HStack(spacing: BrandTokens.Spacing.md) {
                        Button(screenState.transportLabel) {
                            audioManager.togglePlayback()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(screenState.selectedMode.accentColor)

                        FilePickerButton(playerManager: playerManager)
                    }

                    Text(screenState.selectedFileLabel)
                        .font(.footnote)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .padding(BrandTokens.Spacing.lg)
            }
        }
    }

    private func header(for screenState: FlowScreenState) -> some View {
        HStack(alignment: .top, spacing: BrandTokens.Spacing.md) {
            Image("BowlHero")
                .resizable()
                .scaledToFill()
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(BrandTokens.Neutral.border, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Text("FlowTones Runtime")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Accent.gold)
                    .textCase(.uppercase)

                HStack {
                    Text("SonicFlow")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(BrandTokens.Neutral.fg)
                    Spacer()
                    HStack(spacing: BrandTokens.Spacing.sm) {
                        Circle()
                            .fill(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
                            .frame(width: 10, height: 10)
                        Text(screenState.statusLabel)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(BrandTokens.Neutral.muted)
                    }
                    .padding(.horizontal, BrandTokens.Spacing.md)
                    .padding(.vertical, BrandTokens.Spacing.sm)
                    .background(BrandTokens.Neutral.panel, in: Capsule())
                }

                Text("\(screenState.selectedMode.displayName) session with Leopard-backed ambience, pulse shaping, and timed playback.")
                    .font(.subheadline)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var starterPack: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text("Starter Sessions")
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)

            ForEach(FlowToneExample.starterPack) { example in
                Button {
                    audioManager.applyExample(example)
                } label: {
                    HStack(alignment: .top, spacing: BrandTokens.Spacing.sm) {
                        Image(systemName: example.settings.preset.icon)
                            .foregroundStyle(example.settings.mode.accentColor)
                            .frame(width: 24)

                        VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                            Text(example.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(BrandTokens.Neutral.fg)
                            Text(example.subtitle)
                                .font(.caption)
                                .foregroundStyle(BrandTokens.Neutral.muted)
                        }

                        Spacer()

                        Text("\(example.settings.durationMinutes) min")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(example.settings.mode.accentColor)
                    }
                    .padding(BrandTokens.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(BrandTokens.Neutral.panel.opacity(0.9))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
