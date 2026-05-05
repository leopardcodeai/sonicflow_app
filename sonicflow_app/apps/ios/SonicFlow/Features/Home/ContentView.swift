import SwiftUI
import SonicFlowCore

struct ContentView: View {
    @ObservedObject var audioManager: AudioManager
    @AppStorage("sonicflow.hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: SonicFlowTab = .home
    @State private var activeSheet: SonicFlowSheet?
    @State private var librarySearchText = ""

    private let libraryColumns = Array(
        repeating: GridItem(.flexible(), spacing: BrandTokens.Spacing.md),
        count: 2
    )
    private var language: SonicFlowLanguage { .system }

    var body: some View {
        let screenState = FlowScreenState(
            isPlaying: audioManager.isPlaying,
            mode: audioManager.currentMode,
            settings: audioManager.sessionSettings,
            language: language
        )

        ZStack {
            BrandTokens.Neutral.bg
                .ignoresSafeArea()

            LeopardBackgroundView()
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                NavigationStack {
                    homeTab(for: screenState)
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .tabItem {
                    Label(SonicFlowTab.home.localizedTitle(language: language), systemImage: SonicFlowTab.home.systemImage)
                        .accessibilityIdentifier(DesignLabels.Accessibility.homeTab)
                }
                .tag(SonicFlowTab.home)

                NavigationStack {
                    libraryTab(for: screenState)
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .tabItem {
                    Label(SonicFlowTab.library.localizedTitle(language: language), systemImage: SonicFlowTab.library.systemImage)
                        .accessibilityIdentifier(DesignLabels.Accessibility.libraryTab)
                }
                .tag(SonicFlowTab.library)

                NavigationStack {
                    statsTab(for: screenState)
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .tabItem {
                    Label(SonicFlowTab.stats.localizedTitle(language: language), systemImage: SonicFlowTab.stats.systemImage)
                        .accessibilityIdentifier(DesignLabels.Accessibility.statsTab)
                }
                .tag(SonicFlowTab.stats)

                NavigationStack {
                    profileTab(for: screenState)
                }
                .toolbarBackground(.hidden, for: .navigationBar)
                .tabItem {
                    Label(SonicFlowTab.me.localizedTitle(language: language), systemImage: SonicFlowTab.me.systemImage)
                        .accessibilityIdentifier(DesignLabels.Accessibility.profileTab)
                }
                .tag(SonicFlowTab.me)
            }
            .tint(screenState.selectedMode.accentColor)
            .toolbarBackground(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                miniPlayer(for: screenState)
                    .padding(.horizontal, BrandTokens.Spacing.md)
                    .padding(.top, HomeDesignPolicy.miniPlayerVerticalInsetPadding)
                    .padding(.bottom, HomeDesignPolicy.miniPlayerTabBarClearance)
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .timer:
                timerDialSheet(for: screenState)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            case .settings:
                settingsSheet(for: screenState)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .fullScreenCover(isPresented: Binding(get: { !hasCompletedOnboarding }, set: { hasCompletedOnboarding = !$0 })) {
            onboardingScreen()
        }
        .onAppear {
            audioManager.consumeShortcutRequestIfNeeded()
        }
    }

    private func homeTab(for screenState: FlowScreenState) -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: BrandTokens.Spacing.sm), count: 2)

        return ScrollView {
            VStack(spacing: BrandTokens.Spacing.sm) {
                homeHeader(for: screenState)

                if let playbackErrorMessage = audioManager.playbackErrorMessage {
                    playbackErrorBanner(playbackErrorMessage, accent: screenState.selectedMode.accentColor)
                }

                LazyVGrid(columns: columns, spacing: BrandTokens.Spacing.sm) {
                    ForEach(FlowMode.allCases, id: \.self) { mode in
                        gridModeCard(mode: mode, isSelected: mode == screenState.selectedMode)
                    }
                }

                HStack(spacing: BrandTokens.Spacing.sm) {
                    leopardArtwork(accent: screenState.selectedMode.accentColor)
                        .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(language.text(.ember))
                            .font(.subheadline.weight(.black))
                            .foregroundStyle(BrandTokens.Neutral.fg)
                        Text("\(language.modeName(screenState.selectedMode)) · \(Int(screenState.selectedMode.beatHz)) Hz")
                            .font(.caption2)
                            .foregroundStyle(BrandTokens.Neutral.muted)
                    }

                    Spacer()

                    Text(language.text(.high))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(screenState.selectedMode.accentColor)
                        .padding(.horizontal, BrandTokens.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(screenState.selectedMode.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: BrandTokens.Radius.pill, style: .continuous))
                }
                .padding(.horizontal, BrandTokens.Spacing.sm)
                .padding(.vertical, BrandTokens.Spacing.xs)
                .cinematicGlass(radius: BrandTokens.Radius.md, tint: BrandTokens.Neutral.panel.opacity(0.4), stroke: screenState.selectedMode.accentColor.opacity(0.24))

                VisualizerView(isPlaying: audioManager.isPlaying, mode: screenState.selectedMode)
                    .frame(height: 40)

                quickActions(for: screenState)

                compactSessionPanel(for: screenState)
            }
            .padding(.horizontal, BrandTokens.Spacing.md)
            .padding(.top, HomeDesignPolicy.homeVerticalOuterPadding)
            .padding(.bottom, HomeDesignPolicy.homeVerticalOuterPadding)
        }
        .scrollContentBackground(.hidden)
        .background(homeBackdrop())
    }

    private func homeBackdrop() -> some View {
        LeopardBackgroundView()
            .overlay(BrandTokens.Neutral.bg.opacity(HomeDesignPolicy.homeBackdropScrimOpacity))
            .ignoresSafeArea()
    }

    private func gridModeCard(mode: FlowMode, isSelected: Bool) -> some View {
        Button {
            audioManager.currentMode = mode
            if !audioManager.isPlaying {
                audioManager.togglePlayback()
            }
        } label: {
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Circle()
                    .fill(mode.accentColor)
                    .frame(width: 8, height: 8)

                Text(DesignLabels.modeName(mode))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                    .lineLimit(1)

                Text("\(Int(mode.beatHz)) Hz · \(DesignLabels.modeDescription(mode))")
                    .font(.caption2)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .padding(.horizontal, BrandTokens.Spacing.sm)
            .padding(.vertical, BrandTokens.Spacing.sm)
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(mode.accentColor)
                        .padding(BrandTokens.Spacing.sm)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: BrandTokens.Radius.md, style: .continuous)
                    .fill(BrandTokens.Neutral.panel.opacity(isSelected ? 0.76 : 0.58))
                    .overlay(
                        RoundedRectangle(cornerRadius: BrandTokens.Radius.md, style: .continuous)
                            .stroke(isSelected ? mode.accentColor : Color.white.opacity(0.14), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func leopardArtwork(accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BrandTokens.Accent.gold.opacity(0.95), accent.opacity(0.52), BrandTokens.Neutral.ink.opacity(0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: audioManager.isPlaying ? "waveform" : "play.fill")
                .font(.title3.weight(.black))
                .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.9))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
    }

    private func quickActions(for screenState: FlowScreenState) -> some View {
        HStack(spacing: BrandTokens.Spacing.sm) {
            Button {
                activeSheet = .timer
            } label: {
                Label(language.text(.timer), systemImage: "timer")
                    .font(.caption.weight(.semibold))
                    .frame(minHeight: 36)
                    .accessibilityIdentifier(DesignLabels.Accessibility.timerButton)
            }
            .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .secondary))

            Button {
                audioManager.togglePlayback()
            } label: {
                Label(audioManager.isPlaying ? language.text(.pause) : language.text(.play), systemImage: audioManager.isPlaying ? "pause.fill" : "play.fill")
                    .font(.caption.weight(.semibold))
                    .frame(minHeight: 36)
            }
            .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .primary))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }



    private func libraryTab(for screenState: FlowScreenState) -> some View {
        GeometryReader { proxy in
            let contentWidth = max(proxy.size.width - BrandTokens.Spacing.lg * 2, 0)

            ScrollView {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.lg) {
                    sectionHeader(title: language.text(.library), subtitle: language.text(.curatedSessions))

                    HStack(spacing: BrandTokens.Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(BrandTokens.Neutral.muted)
                        TextField(language.text(.searchLibrary), text: $librarySearchText)
                            .textInputAutocapitalization(.never)
                            .foregroundStyle(BrandTokens.Neutral.fg)
                    }
                    .padding(BrandTokens.Spacing.md)
                    .cinematicGlass(radius: 18, tint: BrandTokens.Neutral.panel.opacity(0.25), stroke: Color.white.opacity(0.12))

                    LazyVGrid(columns: libraryColumns, spacing: BrandTokens.Spacing.md) {
                        ForEach(LibrarySession.filtered(librarySearchText)) { session in
                            libraryCard(session, screenState: screenState)
                        }
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, BrandTokens.Spacing.lg)
                .padding(.top, BrandTokens.Spacing.lg)
                .padding(.bottom, BrandTokens.Spacing.lg)
            }
        }
        .scrollContentBackground(.hidden)
        .background(LeopardBackgroundView())
    }

    private func statsTab(for screenState: FlowScreenState) -> some View {
        GeometryReader { proxy in
            let contentWidth = max(proxy.size.width - BrandTokens.Spacing.lg * 2, 0)

            ScrollView {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.lg) {
                    sectionHeader(title: language.text(.stats), subtitle: language.text(.weeklyRhythm))

                    HStack(spacing: BrandTokens.Spacing.md) {
                        statPanel(title: language.text(.thisWeekLabel), value: "4h 32m", symbol: "clock.fill", tint: BrandTokens.Accent.gold)
                        statPanel(title: language.text(.streakLabel), value: "12 days", symbol: "flame.fill", tint: screenState.selectedMode.accentColor)
                    }

                    VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
                        Text(language.text(.systemSurfaces))
                            .font(.headline)
                            .foregroundStyle(BrandTokens.Neutral.fg)

                        ForEach(SystemAffordanceStub.allCases) { affordance in
                            systemAffordanceRow(affordance, tint: screenState.selectedMode.accentColor)
                        }
                    }
                    .padding(BrandTokens.Spacing.md)
                    .cinematicGlass(radius: 24, tint: screenState.selectedMode.accentColor.opacity(0.08), stroke: Color.white.opacity(0.12))
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, BrandTokens.Spacing.lg)
                .padding(.top, BrandTokens.Spacing.lg)
                .padding(.bottom, BrandTokens.Spacing.lg)
            }
        }
        .scrollContentBackground(.hidden)
        .background(
            LeopardBackgroundView()
                .overlay(BrandTokens.Neutral.bg.opacity(0.3))
        )
    }

    private func profileTab(for screenState: FlowScreenState) -> some View {
        GeometryReader { proxy in
            let contentWidth = max(proxy.size.width - BrandTokens.Spacing.lg * 2, 0)

            ScrollView {
                VStack(alignment: .leading, spacing: BrandTokens.Spacing.lg) {
                    HStack(spacing: BrandTokens.Spacing.md) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 54))
                            .foregroundStyle(screenState.selectedMode.accentColor)
                        VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                            Text(language.text(.sonicflow))
                                .font(.title2.weight(.black))
                                .foregroundStyle(BrandTokens.Neutral.fg)
                            Text(language.text(.localFirstProfile))
                                .font(.caption)
                                .foregroundStyle(BrandTokens.Neutral.muted)
                        }
                    }
                    .padding(BrandTokens.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .cinematicGlass(radius: 28, tint: screenState.selectedMode.accentColor.opacity(0.1), stroke: screenState.selectedMode.accentColor.opacity(0.24))

                    Button {
                        activeSheet = .settings
                    } label: {
                        Label(language.text(.settings), systemImage: "gearshape.fill")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .primary))

                    settingsSummary(for: screenState)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.horizontal, BrandTokens.Spacing.lg)
                .padding(.top, BrandTokens.Spacing.lg)
                .padding(.bottom, BrandTokens.Spacing.lg)
            }
        }
        .scrollContentBackground(.hidden)
        .background(LeopardBackgroundView())
    }

    private func onboardingScreen() -> some View {
        let state = OnboardingPanelState(language: language)

        return ZStack {
            BrandTokens.Neutral.bg.ignoresSafeArea()
            LeopardBackgroundView().ignoresSafeArea()

            GeometryReader { proxy in
                let contentWidth = max(min(proxy.size.width - BrandTokens.Spacing.xl * 2, 360), 280)
                let heroWidth = min(contentWidth * 0.72, 216)

                VStack(spacing: BrandTokens.Spacing.lg) {
                    Spacer(minLength: max(BrandTokens.Spacing.lg, proxy.safeAreaInsets.top))

                    onboardingArtwork()
                        .frame(width: heroWidth)

                    VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                    Text(language.text(.sonicflow))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BrandTokens.Accent.gold)
                        .textCase(.uppercase)

                        Text(state.headline)
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(BrandTokens.Neutral.fg)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(3)

                        Text(state.body)
                            .font(.callout)
                            .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.76))
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(width: contentWidth, alignment: .leading)

                    Button {
                        hasCompletedOnboarding = true
                    } label: {
                        Label(state.primaryActionTitle, systemImage: "sparkles")
                            .font(.headline.weight(.bold))
                            .frame(width: contentWidth, height: 54)
                    }
                    .buttonStyle(SonicFlowGlassButtonStyle(tint: BrandTokens.Accent.gold, prominence: .primary, minHeight: 54))

                    Spacer(minLength: max(BrandTokens.Spacing.lg, proxy.safeAreaInsets.bottom))
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .center)
            }
        }
    }

    private func onboardingArtwork() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            BrandTokens.Neutral.panel.opacity(0.96),
                            BrandTokens.Accent.gold.opacity(0.48),
                            BrandTokens.Mode.focus.opacity(0.46)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .fill(BrandTokens.Accent.gold.opacity(0.24))
                .frame(width: 144, height: 144)
                .blur(radius: 18)
                .offset(x: -42, y: -48)

            Circle()
                .fill(BrandTokens.Mode.meditation.opacity(0.28))
                .frame(width: 128, height: 128)
                .blur(radius: 20)
                .offset(x: 48, y: 52)

            VStack(spacing: BrandTokens.Spacing.md) {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(BrandTokens.Neutral.fg)

                HStack(spacing: BrandTokens.Spacing.xs) {
                    ForEach(FlowMode.allCases, id: \.self) { mode in
                        Circle()
                            .fill(mode.accentColor)
                            .frame(width: 11, height: 11)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .overlay(
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.34), radius: 24, y: 12)
    }

    private func sectionHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
            Text(title)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(BrandTokens.Neutral.fg)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(BrandTokens.Neutral.muted)
        }
    }

    private func libraryCard(_ session: LibrarySession, screenState: FlowScreenState) -> some View {
        Button {
            audioManager.sessionSettings = session.settings
            audioManager.currentMode = session.mode
            selectedTab = .home
        } label: {
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
                HStack {
                    Image(systemName: session.settings.preset.icon)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(session.mode.accentColor)
                    Spacer()
                    Text("\(session.settings.durationMinutes) min")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BrandTokens.Accent.gold)
                }

                Spacer(minLength: BrandTokens.Spacing.md)

                Text(session.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(session.subtitle)
                    .font(.caption)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .lineLimit(2)

                Text("\(session.minutesListened) min listened")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(session.mode.accentColor)
            }
            .frame(maxWidth: .infinity, minHeight: 158, alignment: .leading)
            .padding(BrandTokens.Spacing.md)
            .cinematicGlass(radius: 22, tint: session.mode.accentColor.opacity(0.09), stroke: session.mode.accentColor.opacity(0.22))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(session.title), \(session.subtitle)")
    }

    private func statPanel(title: String, value: String, symbol: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.sm) {
            Image(systemName: symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(BrandTokens.Neutral.fg)
            Text(title)
                .font(.caption)
                .foregroundStyle(BrandTokens.Neutral.muted)
        }
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
        .padding(BrandTokens.Spacing.md)
        .cinematicGlass(radius: 22, tint: tint.opacity(0.08), stroke: tint.opacity(0.22))
    }

    private func systemAffordanceRow(_ affordance: SystemAffordanceStub, tint: Color) -> some View {
        HStack(alignment: .top, spacing: BrandTokens.Spacing.md) {
            Image(systemName: affordance.symbolName)
                .font(.headline.weight(.bold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Text(affordance.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                Text(affordance.detail)
                    .font(.caption)
                    .foregroundStyle(BrandTokens.Neutral.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func settingsSummary(for screenState: FlowScreenState) -> some View {
        VStack(alignment: .leading, spacing: BrandTokens.Spacing.md) {
            Text(language.text(.profile))
                .font(.headline)
                .foregroundStyle(BrandTokens.Neutral.fg)
            settingsRow(language.text(.language), value: language == .german ? "Deutsch" : "English", symbol: "globe")
            settingsRow(language.text(.defaultMode), value: language.modeName(screenState.selectedMode), symbol: screenState.selectedMode == .sleep ? "moon.stars.fill" : "waveform")
            settingsRow(language.text(.offline), value: audioManager.offlineAvailability.label, symbol: "arrow.down.circle")
        }
        .padding(BrandTokens.Spacing.md)
        .cinematicGlass(radius: 24, tint: screenState.selectedMode.accentColor.opacity(0.08), stroke: Color.white.opacity(0.12))
    }

    private func settingsRow(_ title: String, value: String, symbol: String) -> some View {
        HStack(spacing: BrandTokens.Spacing.md) {
            Image(systemName: symbol)
                .foregroundStyle(BrandTokens.Accent.gold)
                .frame(width: 28)
            Text(title)
                .foregroundStyle(BrandTokens.Neutral.fg)
            Spacer()
            Text(value)
                .foregroundStyle(BrandTokens.Neutral.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .font(.subheadline.weight(.semibold))
    }

    private func timerDialSheet(for screenState: FlowScreenState) -> some View {
        ZStack {
            BrandTokens.Neutral.bg.ignoresSafeArea()
            VStack(spacing: BrandTokens.Spacing.lg) {
                HStack {
                    Button {
                        activeSheet = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .icon))
                    .accessibilityLabel(language.text(.closeTimer))
                    .accessibilityIdentifier(DesignLabels.Accessibility.closeTimer)

                    Spacer()

                    Text(language.text(.timer).uppercased())
                        .font(.caption.weight(.bold))
                        .foregroundStyle(BrandTokens.Neutral.muted)
                        .tracking(1.4)

                    Spacer()

                    Color.clear
                        .frame(width: 42, height: 42)
                }

                Capsule()
                    .fill(screenState.selectedMode.accentColor.opacity(0.22))
                    .frame(width: 120, height: 120)
                    .overlay(
                        VStack(spacing: BrandTokens.Spacing.xs) {
                            Image(systemName: "timer")
                                .font(.title.weight(.bold))
                            Text(screenState.durationLabel)
                                .font(.title3.weight(.black))
                        }
                        .foregroundStyle(screenState.selectedMode.accentColor)
                    )

                Text(language.text(.timer))
                    .font(.title2.weight(.black))
                    .foregroundStyle(BrandTokens.Neutral.fg)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: BrandTokens.Spacing.sm), count: 3), spacing: BrandTokens.Spacing.sm) {
                    ForEach(TimerDialOption.allCases) { option in
                        Button(option.label) {
                            audioManager.updateDuration(option.minutes)
                        }
                        .frame(maxWidth: .infinity, minHeight: HomeDesignPolicy.primaryActionButtonHeight)
                        .buttonStyle(SonicFlowGlassButtonStyle(
                            tint: screenState.selectedMode.accentColor,
                            prominence: option.minutes == audioManager.sessionSettings.durationMinutes ? .primary : .secondary
                        ))
                    }
                }
            }
            .padding(BrandTokens.Spacing.xl)
        }
    }

    private func settingsSheet(for screenState: FlowScreenState) -> some View {
        ZStack {
            BrandTokens.Neutral.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.lg) {
                HStack(alignment: .top) {
                    sectionHeader(title: language.text(.settings), subtitle: "Profile, audio, and first-run controls")
                    Spacer()
                    Button {
                        activeSheet = nil
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline.weight(.bold))
                            .frame(width: 42, height: 42)
                    }
                    .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .icon))
                    .accessibilityLabel(language.text(.closeSettings))
                    .accessibilityIdentifier(DesignLabels.Accessibility.closeSettings)
                }
                settingsSummary(for: screenState)
                Button {
                    hasCompletedOnboarding = false
                } label: {
                        Label(language.text(.replayOnboarding), systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity, minHeight: 48)
                }
                .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .secondary, minHeight: 48))
                Spacer()
            }
            .padding(BrandTokens.Spacing.lg)
        }
    }

    private func homeHeader(for screenState: FlowScreenState) -> some View {
        HStack(alignment: .center, spacing: BrandTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Text(language.text(.goodMorning))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Text(language.text(.sonicflow))
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundStyle(BrandTokens.Neutral.fg)
            }

            Spacer()

            statusChip(for: screenState)
        }
    }

    private func compactSessionPanel(for screenState: FlowScreenState) -> some View {
        VStack(spacing: BrandTokens.Spacing.sm) {
            HStack {
                Label(language.text(.duration), systemImage: "clock")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Spacer()
                Stepper(screenState.durationLabel, value: Binding(
                    get: { audioManager.sessionSettings.durationMinutes },
                    set: audioManager.updateDuration
                ), in: 5...60, step: 5)
                .tint(screenState.selectedMode.accentColor)
            }

            sliderRow(title: language.text(.neuralLayer), value: "\(Int(audioManager.beatVolume * 100))%", valueBinding: $audioManager.beatVolume, range: 0...1, tint: screenState.selectedMode.accentColor)

            if screenState.showsAdvancedControls {
                sliderRow(title: language.text(.ambientMix), value: "\(Int(screenState.ambientMixValue * 100))%", valueBinding: Binding(
                    get: { audioManager.sessionSettings.ambientMix },
                    set: audioManager.updateAmbientMix
                ), range: 0.2...1, tint: screenState.selectedMode.accentColor)

                sliderRow(title: language.text(.pulseDepth), value: "\(Int(screenState.pulseDepthValue * 100))%", valueBinding: Binding(
                    get: { audioManager.sessionSettings.pulseDepth },
                    set: audioManager.updatePulseDepth
                ), range: 0.2...1, tint: screenState.selectedMode.accentColor)
            }
        }
        .padding(BrandTokens.Spacing.sm)
        .cinematicGlass(radius: BrandTokens.Radius.md, tint: screenState.selectedMode.accentColor.opacity(0.08), stroke: Color.white.opacity(0.14))
    }

    private func sliderRow(title: String, value: String, valueBinding: Binding<Double>, range: ClosedRange<Double>, tint: Color) -> some View {
        VStack(spacing: BrandTokens.Spacing.xs) {
            HStack {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.muted)
                Spacer()
                Text(value)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
            }
            Slider(value: valueBinding, in: range)
                .tint(tint)
        }
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



    private func miniPlayer(for screenState: FlowScreenState) -> some View {
        VStack(spacing: BrandTokens.Spacing.sm) {
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                    Capsule()
                        .fill(screenState.selectedMode.accentColor)
                        .frame(width: proxy.size.width * (audioManager.isPlaying ? 0.38 : 0.08))
                }
            }
            .frame(height: 3)

            HStack(spacing: BrandTokens.Spacing.sm) {
                miniArtwork(accent: screenState.selectedMode.accentColor)

                VStack(alignment: .leading, spacing: BrandTokens.Spacing.xs) {
                Text("\(language.text(.ember)) · \(language.modeName(screenState.selectedMode).lowercased())")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(BrandTokens.Neutral.fg)
                    .lineLimit(1)
                    Text(audioManager.isPlaying ? "23:14 · \(screenState.durationLabel) \(language.text(.timerSuffix))" : language.text(.readyCinematic))
                        .font(.caption)
                        .foregroundStyle(BrandTokens.Neutral.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: BrandTokens.Spacing.sm)

                    Button {
                        audioManager.togglePlayback()
                    } label: {
                        Image(systemName: audioManager.isPlaying ? "pause.fill" : "play.fill")
                            .font(.headline.weight(.black))
                            .frame(width: 40, height: 40)
                    }
                    .buttonStyle(SonicFlowGlassButtonStyle(tint: screenState.selectedMode.accentColor, prominence: .icon))
                    .accessibilityIdentifier(audioManager.isPlaying ? DesignLabels.Accessibility.pauseButton : DesignLabels.Accessibility.playButton)
                }
            }
            .padding(BrandTokens.Spacing.sm)
            .cinematicGlass(
                radius: 22,
                tint: BrandTokens.Neutral.panel.opacity(0.7),
                stroke: screenState.selectedMode.accentColor.opacity(0.28)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 16, y: 8)
        }
        private func miniArtwork(accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [BrandTokens.Accent.gold.opacity(0.9), accent.opacity(0.62)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Image(systemName: "waveform")
                .font(.caption.weight(.black))
                .foregroundStyle(BrandTokens.Neutral.fg.opacity(0.72))
        }
        .frame(width: 38, height: 38)
    }

    private func playbackErrorBanner(_ message: String, accent: Color) -> some View {
        Label(message, systemImage: "speaker.slash.fill")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(BrandTokens.Neutral.fg)
            .padding(BrandTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .cinematicGlass(
                radius: 20,
                tint: accent.opacity(0.12),
                stroke: accent.opacity(0.28),
                interactive: false
            )
    }

}

private struct SonicFlowGlassButtonStyle: ButtonStyle {
    enum Prominence {
        case primary
        case secondary
        case icon
    }

    let tint: Color
    let prominence: Prominence
    var minHeight: CGFloat = HomeDesignPolicy.primaryActionButtonHeight

    func makeBody(configuration: Configuration) -> some View {
        let shape = Capsule(style: .continuous)

        configuration.label
            .foregroundStyle(BrandTokens.Neutral.fg)
            .padding(.horizontal, horizontalPadding)
            .frame(
                minHeight: prominence == .icon ? HomeDesignPolicy.compactIconButtonSize : minHeight
            )
            .background {
                ZStack {
                    shape
                        .fill(BrandTokens.Neutral.panel.opacity(panelOpacity))
                    shape
                        .fill(tint.opacity(tintOpacity(configuration: configuration)))
                }
            }
            .overlay {
                shape
                    .stroke(strokeColor(configuration: configuration), lineWidth: prominence == .primary ? 1.4 : 1)
            }
            .shadow(color: shadowColor, radius: prominence == .primary ? 14 : 8, y: prominence == .primary ? 7 : 3)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }

    private var horizontalPadding: CGFloat {
        prominence == .icon ? 0 : BrandTokens.Spacing.md
    }

    private var panelOpacity: Double {
        switch prominence {
        case .primary:
            return 0.58
        case .secondary:
            return 0.46
        case .icon:
            return 0.42
        }
    }

    private var shadowColor: Color {
        switch prominence {
        case .primary:
            return tint.opacity(0.22)
        case .secondary, .icon:
            return Color.black.opacity(0.18)
        }
    }

    private func tintOpacity(configuration: Configuration) -> Double {
        let pressedBoost = configuration.isPressed ? 0.08 : 0

        switch prominence {
        case .primary:
            return 0.34 + pressedBoost
        case .secondary:
            return 0.1 + pressedBoost
        case .icon:
            return 0.12 + pressedBoost
        }
    }

    private func strokeColor(configuration: Configuration) -> Color {
        switch prominence {
        case .primary:
            return tint.opacity(configuration.isPressed ? 0.72 : 0.5)
        case .secondary, .icon:
            return Color.white.opacity(configuration.isPressed ? 0.24 : 0.16)
        }
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
