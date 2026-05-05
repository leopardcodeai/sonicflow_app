import SwiftUI
import AppIntents
import SonicFlowCore

@main
struct SonicFlowApp: App {
    @StateObject private var audioManager = AudioManager()

    var body: some Scene {
        WindowGroup {
            ContentView(audioManager: audioManager)
                .preferredColorScheme(.dark)
        }
    }
}

enum SonicFlowIntentMode: String, AppEnum {
    case focus
    case flow
    case meditation
    case sleep

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "SonicFlow Mode")
    static var caseDisplayRepresentations: [SonicFlowIntentMode: DisplayRepresentation] = [
        .focus: "Focus",
        .flow: "Flow",
        .meditation: "Meditation",
        .sleep: "Sleep"
    ]

    var flowMode: FlowMode {
        switch self {
        case .focus:
            return .focus
        case .flow:
            return .flow
        case .meditation:
            return .meditation
        case .sleep:
            return .sleep
        }
    }
}

struct SonicFlowShortcutRequest: Codable, Equatable {
    enum Action: String, Codable {
        case start
        case pause
    }

    let action: Action
    let mode: String
    let durationMinutes: Int

    var flowMode: FlowMode {
        switch mode {
        case SonicFlowIntentMode.flow.rawValue:
            return .flow
        case SonicFlowIntentMode.meditation.rawValue:
            return .meditation
        case SonicFlowIntentMode.sleep.rawValue:
            return .sleep
        default:
            return .focus
        }
    }
}

enum SonicFlowShortcutRequestStore {
    private static let key = "sonicflow.shortcutRequest"

    static func save(_ request: SonicFlowShortcutRequest, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(request) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    static func consume(defaults: UserDefaults = .standard) -> SonicFlowShortcutRequest? {
        guard let data = defaults.data(forKey: key),
              let request = try? JSONDecoder().decode(SonicFlowShortcutRequest.self, from: data) else {
            return nil
        }

        defaults.removeObject(forKey: key)
        return request
    }
}

struct StartSonicFlowSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start SonicFlow Session"
    static var description = IntentDescription("Starts SonicFlow with a selected neural mode and session duration.")

    @Parameter(title: "Mode")
    var mode: SonicFlowIntentMode

    @Parameter(title: "Minutes")
    var durationMinutes: Int

    init() {
        mode = .focus
        durationMinutes = 25
    }

    init(mode: SonicFlowIntentMode, durationMinutes: Int = 25) {
        self.mode = mode
        self.durationMinutes = durationMinutes
    }

    func perform() async throws -> some IntentResult {
        SonicFlowShortcutRequestStore.save(
            SonicFlowShortcutRequest(
                action: .start,
                mode: mode.rawValue,
                durationMinutes: max(5, min(60, durationMinutes))
            )
        )
        return .result()
    }
}

struct PauseSonicFlowSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Pause SonicFlow"
    static var description = IntentDescription("Pauses the active SonicFlow session.")

    func perform() async throws -> some IntentResult {
        SonicFlowShortcutRequestStore.save(
            SonicFlowShortcutRequest(action: .pause, mode: SonicFlowIntentMode.focus.rawValue, durationMinutes: 25)
        )
        return .result()
    }
}

struct SonicFlowShortcuts: AppShortcutsProvider {
    static var shortcutTileColor: ShortcutTileColor = .orange

    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartSonicFlowSessionIntent(mode: .focus, durationMinutes: 25),
            phrases: [
                "Start focus with \(.applicationName)",
                "Begin SonicFlow with \(.applicationName)"
            ],
            shortTitle: "Start Focus",
            systemImageName: "waveform"
        )

        AppShortcut(
            intent: StartSonicFlowSessionIntent(mode: .sleep, durationMinutes: 45),
            phrases: [
                "Start sleep with \(.applicationName)",
                "Wind down with \(.applicationName)"
            ],
            shortTitle: "Start Sleep",
            systemImageName: "moon.zzz.fill"
        )

        AppShortcut(
            intent: PauseSonicFlowSessionIntent(),
            phrases: [
                "Pause \(.applicationName)",
                "Stop SonicFlow with \(.applicationName)"
            ],
            shortTitle: "Pause",
            systemImageName: "pause.fill"
        )
    }
}
