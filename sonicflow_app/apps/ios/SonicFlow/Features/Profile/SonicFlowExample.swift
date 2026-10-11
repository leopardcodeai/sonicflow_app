import Foundation

struct SonicFlowExample: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let settings: SonicFlowSettings

    static let starterPack: [SonicFlowExample] = [
        SonicFlowExample(
            id: "focus-primer",
            title: "Focus Primer",
            subtitle: "5 min gamma warmup",
            settings: .standard(for: SonicFlowPreset.focus, durationMinutes: 5)
        ),
        SonicFlowExample(
            id: "flow-reset",
            title: "Flow Reset",
            subtitle: "5 min alpha reset",
            settings: .standard(for: SonicFlowPreset.flow, durationMinutes: 5)
        ),
        SonicFlowExample(
            id: "night-drift",
            title: "Night Drift",
            subtitle: "5 min delta wind-down",
            settings: .standard(for: SonicFlowPreset.sleep, durationMinutes: 5)
        )
    ]
}
