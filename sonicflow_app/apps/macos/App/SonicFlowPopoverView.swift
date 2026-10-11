import AppKit
import SwiftUI

struct SonicFlowPopoverView: View {
    @ObservedObject var audioManager: AudioManager

    private let starterColumns = [GridItem(.flexible(), spacing: BrandTokens.Spacing.sm)]
    private var language: MacSonicFlowLanguage { .system }
    private var isCompact: Bool { audioManager.preferences.popoverDensity == .compact }

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

                    if !isCompact {
                        sessionMetricStrip

                        quickModeSwitcher

                        sessionCluster
                    }

                    starterSessionsPanel

                    if !isCompact {
                        audioMixRulesPanel
                    }

                    popoverFooter
                }
                .padding(BrandTokens.Spacing.md)
            }
        }
        .frame(width: isCompact ? 318 : 340, height: isCompact ? 430 : 560)
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            HStack(alignment: .center, spacing: BrandTokens.Spacing.sm) {
                leopardTile

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text("\(copy(.nowPlaying).uppercased()) · \(language.modeName(audioManager.currentMode).uppercased())")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(BrandTokens.Accent.gold)

                    Text("ember")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(BrandTokens.Neutral.fg)
                        .lineLimit(1)

                    Text("cinematic · \(Int(audioManager.currentPreset.beatFrequencyHz))Hz neural")
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }

            scrubber
        }
        .padding(BrandTokens.Spacing.md)
        .macCinematicGlass(
            radius: 24,
            tint: BrandTokens.Neutral.panel.opacity(0.44),
            stroke: audioManager.currentMode.accentColor.opacity(0.34)
        )
        .shadow(color: Color.black.opacity(0.28), radius: 20, y: 10)
    }

    private var leopardTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BrandTokens.Accent.gold.opacity(0.92), audioManager.currentMode.accentColor.opacity(0.62), BrandTokens.Neutral.ink.opacity(0.86)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: audioManager.isPlaying ? "waveform" : "play.fill")
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.82))
        }
        .frame(width: 48, height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }

    private var scrubber: some View {
        VStack(spacing: BrandTokens.Spacing.xs) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(audioManager.currentMode.accentColor)
                        .frame(width: proxy.size.width * (audioManager.isPlaying ? 0.38 : 0.08))
                    Circle()
                        .fill(BrandTokens.Accent.gold)
                        .frame(width: 10, height: 10)
                        .offset(x: max(0, proxy.size.width * (audioManager.isPlaying ? 0.38 : 0.08) - 5))
                }
            }
            .frame(height: 10)

            HStack {
                Text(audioManager.isPlaying ? "23:14" : "0:00")
                Spacer()
                Text(audioManager.isPlaying ? "-52m \(copy(.left))" : "\(audioManager.durationMinutes)m \(copy(.timer))")
            }
            .font(.caption2.weight(.semibold))
            .foregroundStyle(BrandTokens.Neutral.muted)
        }
    }

    private var transportCluster: some View {
        VStack(spacing: BrandTokens.Spacing.sm) {
            HStack(spacing: BrandTokens.Spacing.sm) {
                Button {
                    audioManager.toggleFavorite(currentExample)
                } label: {
                    Image(systemName: audioManager.isFavorite(currentExample) ? "heart.fill" : "heart")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(audioManager.isFavorite(currentExample) ? BrandTokens.Chakra.root : BrandTokens.Neutral.muted)

                Button {
                    audioManager.togglePlayback()
                } label: {
                    Label(audioManager.isPlaying ? copy(.pause) : copy(.start), systemImage: audioManager.isPlaying ? "pause.fill" : "play.fill")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
                .controlSize(.large)
                .tint(audioManager.currentMode.accentColor)
            }

            Text(copy(.systemMixing))
                .font(.caption.weight(.semibold))
                .foregroundStyle(BrandTokens.Neutral.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(BrandTokens.Spacing.md)
        .macCinematicGlass(
            radius: 26,
            tint: audioManager.currentMode.accentColor.opacity(0.1),
            stroke: Color.white.opacity(0.15)
        )
    }

    private var sessionMetricStrip: some View {
        HStack(spacing: BrandTokens.Spacing.sm) {
            metricBlock(title: copy(.neural), value: copy(.high), tint: audioManager.currentMode.accentColor)
            metricBlock(title: copy(.timer).uppercased(), value: "\(audioManager.durationMinutes)m", tint: BrandTokens.Accent.gold)
            metricBlock(title: copy(.genre), value: "CINEMA", tint: BrandTokens.Neutral.fg.opacity(0.78))
        }
        .padding(BrandTokens.Spacing.sm)
        .macCinematicGlass(
            radius: 20,
            tint: audioManager.currentMode.accentColor.opacity(0.06),
            stroke: Color.white.opacity(0.12),
            interactive: false
        )
    }

    private func metricBlock(title: String, value: String, tint: Color) -> some View {
        VStack(spacing: BrandTokens.Spacing.xs) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(BrandTokens.Neutral.muted)
            Text(value)
                .font(.caption.weight(.black))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }

    private var quickModeSwitcher: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Text(copy(.switchMode))
                .font(.caption2.weight(.bold))
                .foregroundStyle(BrandTokens.Neutral.muted)
                .tracking(1.3)

            VStack(spacing: BrandTokens.Spacing.sm) {
                ForEach(FlowMode.allCases, id: \.self) { mode in
                    ModeCard(mode: mode, isSelected: mode == audioManager.currentMode, language: language) {
                        audioManager.currentMode = mode
                    }
                }
            }
        }
    }

    private var popoverFooter: some View {
        HStack(spacing: BrandTokens.Spacing.sm) {
            SettingsLink {
                Label("Preferences", systemImage: "gearshape")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.capsule)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, BrandTokens.Spacing.xs)
    }

    private var sessionCluster: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text("ember \(copy(.controls))")
                        .font(.headline)
                        .foregroundStyle(audioManager.currentMode.accentColor)
                    Text(copy(.sessionCopy))
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
                Text(copy(.duration))
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
                title: copy(.beatVolume),
                valueLabel: "\(Int(audioManager.beatVolume * 100))%",
                value: $audioManager.beatVolume,
                range: 0...1
            )

            sliderRow(
                title: copy(.ambientMix),
                valueLabel: "\(Int(audioManager.ambientMix * 100))%",
                value: $audioManager.ambientMix,
                range: 0.2...1
            )

            sliderRow(
                title: copy(.pulseDepth),
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
            HStack {
                Text(copy(.recentStarters))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .tracking(1.3)
                Spacer()
                Text(audioManager.favoriteExampleIDs.isEmpty ? "glacier · forest" : "\(audioManager.favoriteExampleIDs.count) favorite")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
            }

            LazyVGrid(columns: starterColumns, spacing: BrandTokens.Spacing.sm) {
                ForEach(starterRows) { example in
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

                            if audioManager.isFavorite(example) {
                                Image(systemName: "heart.fill")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(BrandTokens.Chakra.root)
                            }
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

    private var audioMixRulesPanel: some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                    Text("Audio Mixing")
                        .font(.headline)
                        .foregroundStyle(BrandTokens.Neutral.fg)
                    Text("Active: \(audioManager.activeAudioContext.serviceName) · \(audioManager.activeAudioContext.appName)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(BrandTokens.Neutral.muted)
                }

                Spacer()

                Button {
                    audioManager.refreshActiveAudioContext()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(audioManager.currentMode.accentColor)
            }

            ForEach(audioManager.audioMixRules) { rule in
                HStack(spacing: BrandTokens.Spacing.sm) {
                    VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                        HStack(spacing: BrandTokens.Spacing.xs) {
                            Text(rule.serviceName)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(BrandTokens.Neutral.fg)
                            if audioManager.activeMixRuleID == rule.id {
                                Text("ACTIVE")
                                    .font(.caption2.weight(.black))
                                    .foregroundStyle(audioManager.currentMode.accentColor)
                            }
                        }
                        Text("\(rule.appName) · beat \(Int(rule.beatVolume * 100))% · app \(Int(rule.appVolume * 100))%")
                            .font(.caption2)
                            .foregroundStyle(BrandTokens.Neutral.muted)
                    }

                    Spacer()

                    Picker(rule.serviceName, selection: Binding(
                        get: { rule.behavior },
                        set: { audioManager.updateMixRule(rule, behavior: $0) }
                    )) {
                        ForEach(AudioMixBehavior.allCases) { behavior in
                            Text(behavior.displayName).tag(behavior)
                        }
                    }
                    .labelsHidden()
                    .frame(width: 92)
                }
                .padding(BrandTokens.Spacing.sm)
                .macCinematicGlass(
                    radius: BrandTokens.Radius.md,
                    tint: audioManager.currentMode.accentColor.opacity(0.05),
                    stroke: Color.white.opacity(0.1),
                    interactive: false
                )
            }
        }
        .padding(BrandTokens.Spacing.md)
        .macCinematicGlass(
            radius: 22,
            tint: audioManager.currentMode.accentColor.opacity(0.06),
            stroke: Color.white.opacity(0.12)
        )
    }

    private var currentExample: MacSonicFlowExample {
        MacSonicFlowExample(
            id: "current-\(audioManager.currentPreset.id)",
            title: audioManager.currentPreset.displayName,
            subtitle: "\(Int(audioManager.currentPreset.beatFrequencyHz)) Hz neural",
            preset: audioManager.currentPreset,
            durationMinutes: audioManager.durationMinutes
        )
    }

    private var starterRows: [MacSonicFlowExample] {
        let favorites = MacSonicFlowExample.starterPack.filter { audioManager.isFavorite($0) }
        let recentIDs = Set(audioManager.recentExamples.map(\.id))
        let remainingRecent = audioManager.recentExamples.filter { !favorites.map(\.id).contains($0.id) }
        let starters = MacSonicFlowExample.starterPack.filter { !audioManager.favoriteExampleIDs.contains($0.id) && !recentIDs.contains($0.id) }
        return Array((favorites + remainingRecent + starters).prefix(isCompact ? 3 : 6))
    }

    private func copy(_ key: CopyKey) -> String {
        switch (language, key) {
        case (.english, .nowPlaying): return "Now playing"
        case (.english, .left): return "left"
        case (.english, .timer): return "timer"
        case (.english, .active): return "Active"
        case (.english, .ready): return "Ready"
        case (.english, .pause): return "Pause"
        case (.english, .start): return "Start"
        case (.english, .systemMixing): return "Layers with Spotify, YouTube and Apple Music automatically."
        case (.english, .neural): return "NEURAL"
        case (.english, .high): return "HIGH"
        case (.english, .genre): return "GENRE"
        case (.english, .switchMode): return "SWITCH MODE"
        case (.english, .controls): return "controls"
        case (.english, .sessionCopy): return "Genre stays cinematic; neural and timer remain live controls."
        case (.english, .duration): return "Duration"
        case (.english, .beatVolume): return "Beat volume"
        case (.english, .ambientMix): return "Ambient mix"
        case (.english, .pulseDepth): return "Pulse depth"
        case (.english, .recentStarters): return "RECENT / STARTERS"
        case (.german, .nowPlaying): return "Jetzt lauft"
        case (.german, .left): return "ubrig"
        case (.german, .timer): return "timer"
        case (.german, .active): return "Aktiv"
        case (.german, .ready): return "Bereit"
        case (.german, .pause): return "Pause"
        case (.german, .start): return "Start"
        case (.german, .systemMixing): return "Mischt automatisch mit Spotify, YouTube und Apple Music."
        case (.german, .neural): return "NEURAL"
        case (.german, .high): return "HOCH"
        case (.german, .genre): return "GENRE"
        case (.german, .switchMode): return "MODUS WECHSELN"
        case (.german, .controls): return "steuerung"
        case (.german, .sessionCopy): return "Genre bleibt cinematic; Neural- und Timer-Steuerung bleiben live."
        case (.german, .duration): return "Dauer"
        case (.german, .beatVolume): return "Beat-Lautstarke"
        case (.german, .ambientMix): return "Ambient-Mix"
        case (.german, .pulseDepth): return "Puls-Tiefe"
        case (.german, .recentStarters): return "LETZTE / STARTER"
        }
    }

    private enum CopyKey {
        case nowPlaying, left, timer, active, ready, pause, start, systemMixing
        case neural, high, genre, switchMode, controls, sessionCopy, duration
        case beatVolume, ambientMix, pulseDepth, recentStarters
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
            self
                .background((tint ?? BrandTokens.Neutral.panel).opacity(interactive ? 0.42 : 0.26), in: shape)
                .overlay(shape.stroke(stroke, lineWidth: 1))
        } else {
            self
                .background((tint ?? BrandTokens.Neutral.panel).opacity(interactive ? 0.42 : 0.26), in: shape)
                .overlay(shape.stroke(stroke, lineWidth: 1))
        }
    }
}
