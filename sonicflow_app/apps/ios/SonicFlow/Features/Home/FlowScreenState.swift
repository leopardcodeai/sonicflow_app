import CoreGraphics
import Foundation
import SonicFlowCore

enum SonicFlowTab: String, CaseIterable, Identifiable, Equatable {
    case home
    case library
    case stats
    case me

    var id: String { rawValue }

    var title: String {
        localizedTitle(language: .english)
    }

    var systemImage: String {
        switch self {
        case .home:
            return "sparkles"
        case .library:
            return "square.grid.2x2"
        case .stats:
            return "chart.bar.xaxis"
        case .me:
            return "person.crop.circle"
        }
    }

    func localizedTitle(language: SonicFlowLanguage) -> String {
        switch self {
        case .home:
            return language.text(.home)
        case .library:
            return language.text(.library)
        case .stats:
            return language.text(.stats)
        case .me:
            return language.text(.me)
        }
    }
}

enum SonicFlowSheet: Identifiable, Equatable {
    case timer
    case settings

    var id: String {
        switch self {
        case .timer:
            return "timer"
        case .settings:
            return "settings"
        }
    }
}

enum HomeDesignPolicy {
    static let usesLeopardBackdrop = true
    static let homeBackdropScrimOpacity: Double = 0.18
    static let primaryActionButtonHeight: CGFloat = 44
    static let compactIconButtonSize: CGFloat = 42
    static let constrainsHomeContentToViewport = true
    static let usesLayoutNeutralLeopardBackdrop = true
    static let usesSafeAreaBottomActions = true
    static let horizontalSafeAreaPadding: CGFloat = 16
    static let homeVerticalOuterPadding: CGFloat = 0
    static let miniPlayerVerticalInsetPadding: CGFloat = 0
    static let miniPlayerTabBarClearance: CGFloat = 64
}

struct OnboardingPanelState: Equatable {
    let headline: String
    let body: String
    let primaryActionTitle: String

    init(language: SonicFlowLanguage) {
        headline = language.text(.onboardingHeadline)
        body = language.text(.onboardingBody)
        primaryActionTitle = language.text(.start)
    }
}

struct LibrarySession: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let settings: SonicFlowSettings
    let minutesListened: Int

    var mode: FlowMode { settings.mode }

    static let curated: [LibrarySession] = [
        LibrarySession(id: "ember-focus", title: "Ember Focus", subtitle: "Gamma lift for deep work", settings: .standard(for: SonicFlowPreset.focus, durationMinutes: 25), minutesListened: 184),
        LibrarySession(id: "soft-flow", title: "Soft Flow", subtitle: "Alpha motion for creative work", settings: .standard(for: SonicFlowPreset.flow, durationMinutes: 25), minutesListened: 146),
        LibrarySession(id: "temple-theta", title: "Temple Theta", subtitle: "Theta breathwork and stillness", settings: .standard(for: SonicFlowPreset.meditation, durationMinutes: 20), minutesListened: 96),
        LibrarySession(id: "night-drift", title: "Night Drift", subtitle: "Delta sleep descent", settings: .standard(for: SonicFlowPreset.sleep, durationMinutes: 45), minutesListened: 252),
        LibrarySession(id: "morning-primer", title: "Morning Primer", subtitle: "Five minute focus reset", settings: .standard(for: SonicFlowPreset.focus, durationMinutes: 5), minutesListened: 38),
        LibrarySession(id: "golden-unwind", title: "Golden Unwind", subtitle: "Warm ambient relaxation", settings: .standard(for: SonicFlowPreset.flow, durationMinutes: 10), minutesListened: 74)
    ]

    static func filtered(_ query: String, in sessions: [LibrarySession] = curated) -> [LibrarySession] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedQuery.isEmpty else { return sessions }

        return sessions.filter { session in
            [
                session.title,
                session.subtitle,
                session.mode.displayName,
                session.settings.preset.rawValue
            ]
            .joined(separator: " ")
            .lowercased()
            .contains(normalizedQuery)
        }
    }
}

enum TimerDialOption: Int, CaseIterable, Identifiable, Equatable {
    case five = 5
    case ten = 10
    case twenty = 20
    case twentyFive = 25
    case fortyFive = 45
    case sixty = 60

    var id: Int { rawValue }
    var minutes: Int { rawValue }
    var label: String { "\(minutes) min" }
}

enum SystemAffordanceStub: String, CaseIterable, Identifiable, Equatable {
    case lockScreen
    case dynamicIsland
    case shortcuts

    var id: String { rawValue }

    var title: String {
        switch self {
        case .lockScreen:
            return "Lock Screen"
        case .dynamicIsland:
            return "Dynamic Island"
        case .shortcuts:
            return "Shortcuts"
        }
    }

    var detail: String {
        switch self {
        case .lockScreen:
            return "Live Activity metadata is emitted from playback state for compact timer and neural-layer controls."
        case .dynamicIsland:
            return "A glanceable waveform and session timer can now follow the ActivityKit lifecycle."
        case .shortcuts:
            return "App Shortcuts can start Focus or Sleep sessions and hand the request back into the app."
        }
    }

    var symbolName: String {
        switch self {
        case .lockScreen:
            return "lock.iphone"
        case .dynamicIsland:
            return "capsule.portrait"
        case .shortcuts:
            return "app.badge.checkmark"
        }
    }
}

struct FlowScreenState: Equatable {
    let statusLabel: String
    let transportLabel: String
    let selectedMode: FlowMode
    let durationLabel: String
    let ambientMixValue: Double
    let pulseDepthValue: Double
    let showsAdvancedControls: Bool

    init(
        isPlaying: Bool,
        mode: FlowMode,
        settings: SonicFlowSettings,
        language: SonicFlowLanguage = .english
    ) {
        statusLabel = isPlaying ? language.text(.active) : language.text(.off)
        transportLabel = isPlaying ? language.text(.pause) : language.text(.play)
        selectedMode = mode
        durationLabel = "\(settings.durationMinutes) min"
        ambientMixValue = settings.ambientMix
        pulseDepthValue = settings.pulseDepth
        showsAdvancedControls = true
    }
}
