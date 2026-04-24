import AppKit
import SwiftUI

struct SonicFlowPopoverView: View {
    @ObservedObject var audioManager: AudioManager
    @ObservedObject var playerManager: PlayerManager

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: BrandTokens.Spacing.sm),
        count: 2
    )
    private let starterColumns = [GridItem(.flexible(), spacing: BrandTokens.Spacing.sm)]

    var body: some View {
        ZStack {
            BrandTokens.Neutral.bg
                .ignoresSafeArea()

            LeopardBackgroundView()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
                    hero

                    transportCluster

                    modeGrid

                    sessionCluster

                    starterSessionsPanel

                    sourceCluster
                }
                .padding(BrandTokens.Spacing.md)
            }
        }
        .frame(width: 360, height: 620)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text("SonicFlow")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BrandTokens.Accent.gold)
                        .textCase(.uppercase)

                    Text("SonicFlow Runtime")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.62))
                        .textCase(.uppercase)
                }

                Spacer()

                statusChip
            }

            HStack(alignment: .center, spacing: BrandTokens.Spacing.md) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .interpolation(.high)
                    .frame(width: 54, height: 54)
                    .clipShape(RoundedRectangle(cornerRadius: BrandTokens.Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: BrandTokens.Radius.md, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text(audioManager.currentMode.ritualTitle)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(BrandTokens.Neutral.fg)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)

                    Text(audioManager.currentMode.ritualSummary)
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ViewThatFits(in: .horizontal) {
                HStack(spacing: BrandTokens.Spacing.sm) {
                    metadataPill("\(Int(audioManager.currentPreset.beatFrequencyHz)) Hz", tint: audioManager.currentMode.accentColor)
                    metadataPill("\(audioManager.durationMinutes) min", tint: BrandTokens.Accent.gold)
                    metadataPill(audioManager.currentMode.shortDescription, tint: BrandTokens.Neutral.fg.opacity(0.72))
                }

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                    HStack(spacing: BrandTokens.Spacing.sm) {
                        metadataPill("\(Int(audioManager.currentPreset.beatFrequencyHz)) Hz", tint: audioManager.currentMode.accentColor)
                        metadataPill("\(audioManager.durationMinutes) min", tint: BrandTokens.Accent.gold)
                    }
                    metadataPill(audioManager.currentMode.shortDescription, tint: BrandTokens.Neutral.fg.opacity(0.72))
                }
            }
        }
        .padding(BrandTokens.Spacing.lg)
        .macCinematicGlass(
            radius: 30,
            tint: audioManager.currentMode.accentColor.opacity(0.14),
            stroke: audioManager.currentMode.accentColor.opacity(0.5)
        )
        .shadow(color: audioManager.currentMode.accentColor.opacity(0.26), radius: 36, y: 16)
    }

    private var statusChip: some View {
        Label(
            audioManager.isPlaying ? "Active" : "Ready",
            systemImage: audioManager.isPlaying ? "waveform.circle.fill" : "waveform.circle"
        )
        .font(.caption.weight(.semibold))
        .foregroundStyle(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
        .padding(.horizontal, BrandTokens.Spacing.md)
        .padding(.vertical, BrandTokens.Spacing.sm)
        .macCinematicGlass(radius: BrandTokens.Radius.pill, tint: nil, stroke: Color.white.opacity(0.14), interactive: false)
    }

    private func metadataPill(_ text: String, tint: Color) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.76)
            .padding(.horizontal, BrandTokens.Spacing.md)
            .padding(.vertical, BrandTokens.Spacing.sm)
            .macCinematicGlass(radius: BrandTokens.Radius.pill, tint: tint.opacity(0.12), stroke: tint.opacity(0.24), interactive: false)
    }

    private var transportCluster: some View {
        HStack(spacing: BrandTokens.Spacing.sm) {
            Button {
                audioManager.togglePlayback()
            } label: {
                Label(audioManager.isPlaying ? "Pause" : "Start", systemImage: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.headline.weight(.bold))
                    .frame(maxWidth: .infinity, minHeight: 46)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .tint(audioManager.currentMode.accentColor)

            Picker("Source", selection: $audioManager.selectedSource) {
                Text("Overlay").tag(AudioSource.system)
                Text("File").tag(AudioSource.file)
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .frame(width: 132)
        }
        .padding(BrandTokens.Spacing.md)
        .macCinematicGlass(
            radius: 26,
            tint: audioManager.currentMode.accentColor.opacity(0.1),
            stroke: Color.white.opacity(0.15)
        )
    }

    private var modeGrid: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text("Choose ritual")
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)

            LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.sm) {
                ForEach(FlowMode.allCases, id: \.self) { mode in
                    ModeCard(mode: mode, isSelected: mode == audioManager.currentMode) {
                        audioManager.currentMode = mode
                    }
                }
            }
        }
    }

    private var sessionCluster: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text(audioManager.currentPreset.displayName)
                        .font(.headline)
                        .foregroundStyle(audioManager.currentMode.accentColor)
                    Text(audioManager.currentPreset.summary)
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Text("\(Int(audioManager.currentPreset.carrierFrequencyHz)) Hz carrier")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.72))
            }

            HStack {
                Text("Duration")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Spacer()
                Stepper(value: $audioManager.durationMinutes, in: 5...60, step: 5) {
                    Text("\(audioManager.durationMinutes) min")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(BrandTokens.Neutral.fg)
                }
            }

            sliderRow(
                title: "Beat volume",
                valueLabel: "\(Int(audioManager.beatVolume * 100))%",
                value: $audioManager.beatVolume,
                range: 0...1
            )

            sliderRow(
                title: "Ambient mix",
                valueLabel: "\(Int(audioManager.ambientMix * 100))%",
                value: $audioManager.ambientMix,
                range: 0.2...1
            )

            sliderRow(
                title: "Pulse depth",
                valueLabel: "\(Int(audioManager.pulseDepth * 100))%",
                value: $audioManager.pulseDepth,
                range: 0.2...1
            )
        }
        .padding(BrandTokens.Spacing.md)
        .macCinematicGlass(
            radius: 24,
            tint: audioManager.currentMode.accentColor.opacity(0.08),
            stroke: Color.white.opacity(0.14)
        )
    }

    private func sliderRow(
        title: String,
        valueLabel: String,
        value: Binding<Double>,
        range: ClosedRange<Double>
    ) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
            HStack {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Spacer()
                Text(valueLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
            }

            Slider(value: value, in: range)
                .tint(audioManager.currentMode.accentColor)
        }
    }

    private var starterSessionsPanel: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text("Starter Sessions")
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)

            LazyVGrid(columns: starterColumns, spacing: BrandTokens.Spacing.sm) {
                ForEach(MacSonicFlowExample.starterPack) { example in
                    Button {
                        audioManager.applyExample(example)
                    } label: {
                        HStack(alignment: .center, spacing: BrandTokens.Spacing.sm) {
                            Image(systemName: "sparkles")
                                .foregroundStyle(example.preset.mode.accentColor)
                                .frame(width: 28, height: 28)
                                .background(example.preset.mode.accentColor.opacity(0.16), in: Circle())

                            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                                Text(example.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(BrandTokens.Neutral.fg)
                                Text(example.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(BrandTokens.Neutral.muted)
                            }

                            Spacer()

                            Text("\(example.durationMinutes) min")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(example.preset.mode.accentColor)
                        }
                        .padding(BrandTokens.Spacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .macCinematicGlass(
                            radius: BrandTokens.Radius.lg,
                            tint: example.preset.mode.accentColor.opacity(0.08),
                            stroke: example.preset.mode.accentColor.opacity(0.24)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var sourceCluster: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text("Overlay Mode")
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)

            sourceSection

            sourceStatus
        }
        .padding(BrandTokens.Spacing.md)
        .macCinematicGlass(
            radius: 22,
            tint: audioManager.currentMode.accentColor.opacity(0.06),
            stroke: Color.white.opacity(0.12)
        )
    }

    @ViewBuilder
    private var sourceSection: some View {
        switch audioManager.selectedSource {
        case .system:
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                Text(audioManager.canCaptureSystemAudio ? "macOS system overlay ready" : "Overlay capture needs macOS 14.2")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(
                        audioManager.canCaptureSystemAudio
                            ? BrandTokens.Neutral.fg.opacity(0.74)
                            : BrandTokens.Chakra.sacral
                    )
                Text("Permission: \(audioManager.systemAudioPermissionStatus)")
                    .font(.caption)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Button("Start Overlay Capture") {
                    audioManager.startSystemAudioCapture()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .disabled(!audioManager.canCaptureSystemAudio)
            }
        case .file:
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                Button(playerManager.selectedFileURL == nil ? "Pick File" : "Replace File") {
                    playerManager.pickAudioFile()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)

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

    private var sourceStatus: some View {
        HStack(spacing: BrandTokens.Spacing.sm) {
            Image(systemName: audioManager.selectedSource == .system ? "macwindow.on.rectangle" : "music.note")
                .foregroundStyle(audioManager.currentMode.accentColor)
            Text(sourceStatusText)
                .font(.caption)
                .foregroundStyle(BrandTokens.Neutral.muted)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private var sourceStatusText: String {
        if audioManager.selectedSource == .file, let selectedFileURL = playerManager.selectedFileURL {
            return selectedFileURL.lastPathComponent
        }

        return audioManager.selectedFileLabel
    }
}

private extension View {
    @ViewBuilder
    func macCinematicGlass(
        radius: CGFloat,
        tint: Color?,
        stroke: Color,
        interactive: Bool = true
    ) -> some View {
        let shape = RoundedRectangle(cornerRadius: radius, style: .continuous)

        if #available(macOS 26.0, *) {
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
                .background(.thinMaterial, in: shape)
                .overlay(shape.stroke(stroke, lineWidth: 1))
        }
    }
}
