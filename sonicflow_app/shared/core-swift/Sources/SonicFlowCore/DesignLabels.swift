import Foundation

public enum SonicFlowLanguage {
    case english
    case german

    public static var system: SonicFlowLanguage {
        let preferred = Locale.preferredLanguages.first ?? Locale.current.identifier
        return preferred.lowercased().hasPrefix("de") ? .german : .english
    }

    public func text(_ key: Key) -> String {
        switch (self, key) {
        case (.english, .active): return "Active"
        case (.english, .off): return "Off"
        case (.english, .play): return "Play"
        case (.english, .pause): return "Pause"
        case (.english, .goodMorning): return "good morning,"
        case (.english, .thisWeek): return "4h 32m this wk"
        case (.english, .nowPlaying): return "now playing"
        case (.english, .focusDeep): return "FOCUS · DEEP"
        case (.english, .neural): return "NEURAL"
        case (.english, .timer): return "TIMER"
        case (.english, .genre): return "GENRE"
        case (.english, .high): return "HIGH"
        case (.english, .cinematic): return "CINEMATIC"
        case (.english, .readyCinematic): return "ready · cinematic neural"
        case (.english, .whatNeed): return "WHAT DO YOU NEED?"
        case (.english, .duration): return "Duration"
        case (.english, .neuralLayer): return "Neural layer"
        case (.english, .ambientMix): return "Ambient mix"
        case (.english, .pulseDepth): return "Pulse depth"
        case (.english, .offlineSession): return "Offline session"
        case (.english, .offlineCopy): return "Download the generated session manifest for mobile offline playback."
        case (.english, .download): return "Download"
        case (.english, .delete): return "Delete"
        case (.english, .starterSessions): return "Starter Sessions"
        case (.english, .timerSuffix): return "timer"
        case (.english, .home): return "Home"
        case (.english, .library): return "Library"
        case (.english, .stats): return "Stats"
        case (.english, .me): return "Me"
        case (.english, .onboardingHeadline): return "Tune the room before you begin"
        case (.english, .onboardingBody): return "Choose a session, shape the neural layer, and keep SonicFlow ready from your phone surface."
        case (.english, .start): return "Start"
        case (.english, .searchLibrary): return "Search library"
        case (.english, .settings): return "Settings"
        case (.english, .sonicflow): return "sonicflow"
        case (.english, .ember): return "ember"
        case (.english, .streak): return "12 day streak"
        case (.english, .replayOnboarding): return "Replay onboarding"
        case (.english, .profile): return "Profile"
        case (.english, .language): return "Language"
        case (.english, .defaultMode): return "Default mode"
        case (.english, .offline): return "Offline"
        case (.english, .localFirstProfile): return "Local-first listening profile"
        case (.english, .curatedSessions): return "Curated SonicFlow sessions"
        case (.english, .weeklyRhythm): return "Weekly rhythm and surface readiness"
        case (.english, .thisWeekLabel): return "This week"
        case (.english, .streakLabel): return "Streak"
        case (.english, .systemSurfaces): return "System surfaces"
        case (.english, .closeTimer): return "Close timer"
        case (.english, .closeSettings): return "Close settings"
        case (.english, .closePlayer): return "Close player"
        case (.english, .notDownloaded): return "Not downloaded"
        case (.english, .downloadedForOffline): return "Downloaded for offline"
        case (.english, .storageFull): return "Storage full"
        case (.english, .audioEngineError): return "Audio engine could not start."
        case (.english, .minutesListened): return "min listened"
        case (.english, .minutes): return "min"
        case (.english, .mix): return "mix"
        case (.english, .neuralHz): return "Hz neural"
        case (.english, .startFocus): return "Start Focus"
        case (.english, .startSleep): return "Start Sleep"
        case (.english, .startSonicFlowSession): return "Start SonicFlow Session"
        case (.english, .startSonicFlowDescription): return "Starts SonicFlow with a selected neural mode and session duration."
        case (.english, .pauseSonicFlow): return "Pause SonicFlow"
        case (.english, .pauseSonicFlowDescription): return "Pauses the active SonicFlow session."
        case (.english, .sonicFlowMode): return "SonicFlow Mode"
        case (.english, .mode): return "Mode"
        case (.english, .minutesParam): return "Minutes"

        case (.german, .active): return "Aktiv"
        case (.german, .off): return "Aus"
        case (.german, .play): return "Abspielen"
        case (.german, .pause): return "Pause"
        case (.german, .goodMorning): return "guten morgen,"
        case (.german, .thisWeek): return "4h 32m diese woche"
        case (.german, .nowPlaying): return "jetzt lauft"
        case (.german, .focusDeep): return "FOKUS · DEEP"
        case (.german, .neural): return "NEURAL"
        case (.german, .timer): return "TIMER"
        case (.german, .genre): return "GENRE"
        case (.german, .high): return "HOCH"
        case (.german, .cinematic): return "CINEMATIC"
        case (.german, .readyCinematic): return "bereit · cinematic neural"
        case (.german, .whatNeed): return "WAS BRAUCHST DU?"
        case (.german, .duration): return "Dauer"
        case (.german, .neuralLayer): return "Neurale Ebene"
        case (.german, .ambientMix): return "Ambient-Mix"
        case (.german, .pulseDepth): return "Puls-Tiefe"
        case (.german, .offlineSession): return "Offline-Session"
        case (.german, .offlineCopy): return "Lade das generierte Session-Manifest fur mobile Offline-Wiedergabe."
        case (.german, .download): return "Laden"
        case (.german, .delete): return "Loschen"
        case (.german, .starterSessions): return "Starter-Sessions"
        case (.german, .timerSuffix): return "timer"
        case (.german, .home): return "Home"
        case (.german, .library): return "Bibliothek"
        case (.german, .stats): return "Stats"
        case (.german, .me): return "Ich"
        case (.german, .onboardingHeadline): return "Stimme den Raum ein, bevor du beginnst"
        case (.german, .onboardingBody): return "Wahle eine Session, forme die neurale Ebene und halte SonicFlow auf dem iPhone bereit."
        case (.german, .start): return "Starten"
        case (.german, .searchLibrary): return "Bibliothek suchen"
        case (.german, .settings): return "Einstellungen"
        case (.german, .sonicflow): return "sonicflow"
        case (.german, .ember): return "ember"
        case (.german, .streak): return "12-Tage-Serie"
        case (.german, .replayOnboarding): return "Onboarding wiederholen"
        case (.german, .profile): return "Profil"
        case (.german, .language): return "Sprache"
        case (.german, .defaultMode): return "Standard-Modus"
        case (.german, .offline): return "Offline"
        case (.german, .localFirstProfile): return "Lokales Horprofil"
        case (.german, .curatedSessions): return "Kuratierte SonicFlow-Sessions"
        case (.german, .weeklyRhythm): return "Wochenrhythmus und Surface-Bereitschaft"
        case (.german, .thisWeekLabel): return "Diese Woche"
        case (.german, .streakLabel): return "Serie"
        case (.german, .systemSurfaces): return "System-Oberflachen"
        case (.german, .closeTimer): return "Timer schlieBen"
        case (.german, .closeSettings): return "Einstellungen schlieBen"
        case (.german, .closePlayer): return "Player schlieBen"
        case (.german, .notDownloaded): return "Nicht geladen"
        case (.german, .downloadedForOffline): return "Fur Offline geladen"
        case (.german, .storageFull): return "Speicher voll"
        case (.german, .audioEngineError): return "Audio-Engine konnte nicht starten."
        case (.german, .minutesListened): return "min gehort"
        case (.german, .minutes): return "min"
        case (.german, .mix): return "Mix"
        case (.german, .neuralHz): return "Hz neural"
        case (.german, .startFocus): return "Fokus starten"
        case (.german, .startSleep): return "Schlaf starten"
        case (.german, .startSonicFlowSession): return "SonicFlow-Session starten"
        case (.german, .startSonicFlowDescription): return "Startet SonicFlow mit einem gewahlten Neural-Modus und einer Session-Dauer."
        case (.german, .pauseSonicFlow): return "SonicFlow pausieren"
        case (.german, .pauseSonicFlowDescription): return "Pausiert die aktive SonicFlow-Session."
        case (.german, .sonicFlowMode): return "SonicFlow-Modus"
        case (.german, .mode): return "Modus"
        case (.german, .minutesParam): return "Minuten"
        }
    }

    public func modeName(_ mode: FlowMode) -> String {
        switch (self, mode) {
        case (.german, .focus): return "Fokus"
        case (.german, .flow): return "Flow"
        case (.german, .meditation): return "Meditation"
        case (.german, .sleep): return "Schlaf"
        default:
            switch mode {
            case .focus: return "Focus"
            case .flow: return "Flow"
            case .meditation: return "Meditation"
            case .sleep: return "Sleep"
            }
        }
    }

    public func modeDescription(_ mode: FlowMode) -> String {
        switch (self, mode) {
        case (.german, .focus): return "Gamma-Fokus-Boost"
        case (.german, .flow): return "Alpha-Konzentration"
        case (.german, .meditation): return "Theta-Ruhe-Tiefe"
        case (.german, .sleep): return "Delta-Tiefenruhe"
        default:
            switch mode {
            case .focus: return "Gamma focus boost"
            case .flow: return "Alpha concentration"
            case .meditation: return "Theta calm depth"
            case .sleep: return "Delta deep rest"
            }
        }
    }

    public enum Key {
        case active, off, play, pause
        case goodMorning, thisWeek, nowPlaying, focusDeep, neural, timer, genre, high, cinematic
        case readyCinematic, whatNeed, duration, neuralLayer, ambientMix, pulseDepth
        case offlineSession, offlineCopy, download, delete, starterSessions, timerSuffix
        case home, library, stats, me, onboardingHeadline, onboardingBody, start, searchLibrary, settings
        case sonicflow, ember, streak, replayOnboarding
        case profile, language, defaultMode, offline, localFirstProfile
        case curatedSessions, weeklyRhythm, thisWeekLabel, streakLabel, systemSurfaces
        case closeTimer, closeSettings, closePlayer
        case notDownloaded, downloadedForOffline, storageFull
        case audioEngineError, minutesListened, minutes, mix, neuralHz
        case startFocus, startSleep
        case startSonicFlowSession, startSonicFlowDescription
        case pauseSonicFlow, pauseSonicFlowDescription
        case sonicFlowMode, mode, minutesParam
    }
}

public enum DesignLabels {
    public enum Accessibility {
        public static let playButton = "audio_play"
        public static let pauseButton = "audio_pause"
        public static let closeTimer = "close_timer"
        public static let closeSettings = "close_settings"
        public static let closePlayer = "close_player"
        public static let startSession = "start_session"
        public static let modeCard = "mode_card"
        public static let modeCardFocus = "mode_card_focus"
        public static let modeCardFlow = "mode_card_flow"
        public static let modeCardMeditation = "mode_card_meditation"
        public static let modeCardSleep = "mode_card_sleep"
        public static let libraryCard = "library_card"
        public static let downloadButton = "download_session"
        public static let deleteButton = "delete_session"
        public static let settingsButton = "open_settings"
        public static let timerButton = "open_timer"
        public static let homeTab = "tab_home"
        public static let libraryTab = "tab_library"
        public static let statsTab = "tab_stats"
        public static let profileTab = "tab_profile"
        public static let libraryHeader = "library_header"
        public static let nowPlayingButton = "now_playing"
        public static let replayOnboarding = "replay_onboarding"

        public static func modeCard(for mode: FlowMode) -> String {
            switch mode {
            case .focus: return modeCardFocus
            case .flow: return modeCardFlow
            case .meditation: return modeCardMeditation
            case .sleep: return modeCardSleep
            }
        }
    }

    public static func text(_ key: SonicFlowLanguage.Key, language: SonicFlowLanguage = .system) -> String {
        language.text(key)
    }

    public static func modeName(_ mode: FlowMode, language: SonicFlowLanguage = .system) -> String {
        language.modeName(mode)
    }

    public static func modeDescription(_ mode: FlowMode, language: SonicFlowLanguage = .system) -> String {
        language.modeDescription(mode)
    }
}
