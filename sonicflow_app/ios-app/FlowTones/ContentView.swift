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
                    hero(for: screenState)

                    VisualizerView(
                        isPlaying: audioManager.isPlaying,
                        mode: screenState.selectedMode
                    )

                    transportPanel(for: screenState)

                    modeSelector(for: screenState)

                    sessionPanel(for: screenState)

                    overlayCapabilityNote(for: screenState)

                    starterPack

                    selectedSourceLabel(for: screenState)
                }
                .padding(BrandTokens.Spacing.lg)
                .padding(.bottom, BrandTokens.Spacing.lg)
            }
        }
    }

    private func hero(for screenState: FlowScreenState) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text("SonicFlow")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BrandTokens.Accent.gold)
                        .textCase(.uppercase)

                    Text("FlowTones Runtime")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.62))
                        .textCase(.uppercase)
                }

                Spacer()

                statusChip(for: screenState)
            }

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                Text(screenState.selectedMode.ritualTitle)
                    .font(.system(size: 48, weight: .black, design: .rounded))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)

                Text(screenState.selectedMode.ritualSummary)
                    .font(.subheadline)
                    .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.78))
                    .fixedSize(horizontal: false, vertical: true)
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: BrandTokens.Spacing.sm) {
                    metadataPill("\(Int(screenState.selectedMode.beatHz)) Hz", tint: screenState.selectedMode.accentColor)
                    metadataPill(screenState.durationLabel, tint: BrandTokens.Accent.gold)
                    metadataPill(screenState.selectedMode.shortDescription, tint: BrandTokens.Neutral.fg.opacity(0.72))
                }

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                    HStack(spacing: BrandTokens.Spacing.sm) {
                        metadataPill("\(Int(screenState.selectedMode.beatHz)) Hz", tint: screenState.selectedMode.accentColor)
                        metadataPill(screenState.durationLabel, tint: BrandTokens.Accent.gold)
                    }
                    metadataPill(screenState.selectedMode.shortDescription, tint: BrandTokens.Neutral.fg.opacity(0.72))
                }
            }
        }
        .padding(BrandTokens.Spacing.lg)
        .cinematicGlass(
            radius: 34,
            tint: screenState.selectedMode.accentColor.opacity(0.16),
            stroke: screenState.selectedMode.accentColor.opacity(0.52)
        )
        .shadow(color: screenState.selectedMode.accentColor.opacity(0.32), radius: 44, y: 18)
    }

    private func statusChip(for screenState: FlowScreenState) -> some View {
        Label(
            screenState.statusLabel,
            systemImage: audioManager.isPlaying ? "waveform.circle.fill" : "waveform.circle"
        )
        .font(.caption.weight(.semibold))
        .foregroundStyle(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
        .padding(.horizontal, BrandTokens.Spacing.md)
        .padding(.vertical, BrandTokens.Spacing.sm)
        .cinematicGlass(radius: BrandTokens.Radius.pill, tint: nil, stroke: Color.white.opacity(0.14), interactive: false)
    }

    private func metadataPill(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .padding(.horizontal, BrandTokens.Spacing.md)
            .padding(.vertical, BrandTokens.Spacing.sm)
            .cinematicGlass(radius: BrandTokens.Radius.pill, tint: tint.opacity(0.12), stroke: tint.opacity(0.24), interactive: false)
    }

    private func transportPanel(for screenState: FlowScreenState) -> some View {
        HStack(spacing: BrandTokens.Spacing.md) {
            Button {
                audioManager.togglePlayback()
            } label: {
                Label(
                    screenState.transportLabel,
                    systemImage: audioManager.isPlaying ? "pause.fill" : "play.fill"
                )
                .font(.headline.weight(.bold))
                .frame(width: 128, height: 58)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .tint(screenState.selectedMode.accentColor)
            .shadow(color: screenState.selectedMode.accentColor.opacity(0.42), radius: 28, y: 10)

            FilePickerButton(playerManager: playerManager)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(BrandTokens.Spacing.md)
        .cinematicGlass(
            radius: 30,
            tint: screenState.selectedMode.accentColor.opacity(0.1),
            stroke: Color.white.opacity(0.16)
        )
    }

    private func modeSelector(for screenState: FlowScreenState) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text("Choose ritual")
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)

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
        }
    }

    private func sessionPanel(for screenState: FlowScreenState) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
            HStack {
                Text("Session shaping")
                    .font(.headline)
                    .foregroundStyle(BrandTokens.Neutral.fg)
                Spacer()
                Text("\(Int(screenState.ambientMixValue * 100))% mix")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(screenState.selectedMode.accentColor)
            }

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

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                controlHeader("Neural layer", value: "\(Int(audioManager.beatVolume * 100))%")
                Slider(value: $audioManager.beatVolume, in: 0...1)
                    .tint(screenState.selectedMode.accentColor)
            }

            if screenState.showsAdvancedControls {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    controlHeader("Ambient mix", value: "\(Int(screenState.ambientMixValue * 100))%")
                    Slider(
                        value: Binding(
                            get: { audioManager.sessionSettings.ambientMix },
                            set: audioManager.updateAmbientMix
                        ),
                        in: 0.2...1
                    )
                    .tint(screenState.selectedMode.accentColor)
                }

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    controlHeader("Pulse depth", value: "\(Int(screenState.pulseDepthValue * 100))%")
                    Slider(
                        value: Binding(
                            get: { audioManager.sessionSettings.pulseDepth },
                            set: audioManager.updatePulseDepth
                        ),
                        in: 0.2...1
                    )
                    .tint(screenState.selectedMode.accentColor)
                }
            }
        }
        .padding(BrandTokens.Spacing.lg)
        .cinematicGlass(
            radius: 28,
            tint: screenState.selectedMode.accentColor.opacity(0.09),
            stroke: Color.white.opacity(0.14)
        )
    }

    private func controlHeader(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandTokens.Neutral.muted)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandTokens.Neutral.fg)
        }
    }

    private func overlayCapabilityNote(for screenState: FlowScreenState) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Label(screenState.overlayModeTitle, systemImage: "rectangle.on.rectangle")
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)

            Text(screenState.overlayModeStatus)
                .font(.footnote)
                .foregroundStyle(BrandTokens.Neutral.muted)
                .fixedSize(horizontal: false, vertical: true)

            metadataPill("Local file layer", tint: screenState.selectedMode.accentColor)
        }
        .padding(BrandTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .cinematicGlass(
            radius: 24,
            tint: screenState.selectedMode.accentColor.opacity(0.07),
            stroke: Color.white.opacity(0.12)
        )
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
                    HStack(alignment: .center, spacing: BrandTokens.Spacing.sm) {
                        Image(systemName: example.settings.preset.icon)
                            .foregroundStyle(example.settings.mode.accentColor)
                            .frame(width: 28, height: 28)
                            .background(example.settings.mode.accentColor.opacity(0.16), in: Circle())

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
                            .font(.caption.weight(.bold))
                            .foregroundStyle(example.settings.mode.accentColor)
                    }
                    .padding(BrandTokens.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cinematicGlass(
                        radius: 22,
                        tint: example.settings.mode.accentColor.opacity(0.08),
                        stroke: example.settings.mode.accentColor.opacity(0.24)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func selectedSourceLabel(for screenState: FlowScreenState) -> some View {
        Label(screenState.selectedFileLabel, systemImage: "music.note")
            .font(.footnote)
            .foregroundStyle(BrandTokens.Neutral.muted)
            .lineLimit(1)
            .truncationMode(.middle)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, BrandTokens.Spacing.md)
    }
}

private extension View {
    @ViewBuilder
    func cinematicGlass(
        radius: CGFloat,
        tint: Color?,
        stroke: Color,
        interactive: Bool = true
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        if #available(iOS 26.0, *) {
            if interactive {
                self
                    .glassEffect(.regular.tint(tint).interactive(), in: shape)
                    .overlay(shape.stroke(stroke, lineWidth: 1))
            } else {
                self
                    .glassEffect(.regular.tint(tint), in: shape)
                    .overlay(shape.stroke(stroke, lineWidth: 1))
            }
        } else {
            self
                .background(.ultraThinMaterial, in: shape)
                .overlay(shape.stroke(stroke, lineWidth: 1))
        }
    }
}
