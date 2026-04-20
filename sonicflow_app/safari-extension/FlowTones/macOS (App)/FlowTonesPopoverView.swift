import AppKit
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
                hero

                statusStrip

                LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.sm) {
                    ForEach(FlowMode.allCases, id: \.self) { mode in
                        ModeCard(mode: mode, isSelected: mode == audioManager.currentMode) {
                            audioManager.currentMode = mode
                        }
                    }
                }

                controlPanel

                sourceSection

                atmospherePanel

                sourceStatus

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
        .frame(width: 320, height: 470)
    }

    private var hero: some View {
        HStack(alignment: .top, spacing: BrandTokens.Spacing.sm) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: BrandTokens.Radius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: BrandTokens.Radius.md)
                        .stroke(BrandTokens.Neutral.border, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Text("FlowTones Runtime")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Accent.gold)
                    .textCase(.uppercase)
                Text("SonicFlow")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                Text("\(audioManager.currentMode.displayName) session with Leopard-backed ambience, pulse shaping, and native routing.")
                    .font(.caption)
                    .foregroundStyle(BrandTokens.Neutral.muted)
            }
        }
    }

    private var statusStrip: some View {
        HStack {
            Label(audioManager.statusText, systemImage: audioManager.isPlaying ? "waveform.circle.fill" : "waveform.circle")
                .font(.caption)
                .foregroundStyle(audioManager.isPlaying ? BrandTokens.Accent.success : BrandTokens.Neutral.muted)
            Spacer()
            Text("\(Int(audioManager.currentMode.beatHz)) Hz")
                .font(.caption.weight(.medium))
                .foregroundStyle(audioManager.currentMode.accentColor)
        }
        .padding(BrandTokens.Spacing.sm)
        .background(BrandTokens.Neutral.panel.opacity(0.88), in: RoundedRectangle(cornerRadius: BrandTokens.Radius.md))
    }

    private var controlPanel: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Picker("Source", selection: $audioManager.selectedSource) {
                Text("System audio").tag(AudioSource.system)
                Text("File").tag(AudioSource.file)
            }
            .pickerStyle(.segmented)

            HStack {
                Text("Duration")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Spacer()
                Stepper(value: $audioManager.durationMinutes, in: 5...60, step: 5) {
                    Text("\(audioManager.durationMinutes) min")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.fg)
                }
            }

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
                Text("Beat volume")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Slider(value: $audioManager.beatVolume, in: 0...1)
                    .tint(audioManager.currentMode.accentColor)
            }
        }
        .padding(BrandTokens.Spacing.md)
        .background(BrandTokens.Neutral.panel.opacity(0.9), in: RoundedRectangle(cornerRadius: BrandTokens.Radius.md))
    }

    private var atmospherePanel: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text("Atmosphere")
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandTokens.Neutral.muted)

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
                HStack {
                    Text("Ambient mix")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                    Spacer()
                    Text("\(Int(audioManager.ambientMix * 100))%")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.fg)
                }
                Slider(value: $audioManager.ambientMix, in: 0.2...1)
                    .tint(audioManager.currentMode.accentColor)
            }

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs + 2) {
                HStack {
                    Text("Pulse depth")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                    Spacer()
                    Text("\(Int(audioManager.pulseDepth * 100))%")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.fg)
                }
                Slider(value: $audioManager.pulseDepth, in: 0.2...1)
                    .tint(audioManager.currentMode.accentColor)
            }
        }
        .padding(BrandTokens.Spacing.md)
        .background(BrandTokens.Neutral.panel.opacity(0.9), in: RoundedRectangle(cornerRadius: BrandTokens.Radius.md))
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
