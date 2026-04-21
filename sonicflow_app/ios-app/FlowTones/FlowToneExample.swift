import Foundation

struct FlowToneExample: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let settings: FlowToneSettings

    static let starterPack: [FlowToneExample] = [
        FlowToneExample(
            id: "focus-primer",
            title: "Focus Primer",
            subtitle: "5 min gamma warmup",
            settings: .standard(for: FlowTonePreset.focus, durationMinutes: 5)
        ),
        FlowToneExample(
            id: "flow-reset",
            title: "Flow Reset",
            subtitle: "5 min alpha reset",
            settings: .standard(for: FlowTonePreset.flow, durationMinutes: 5)
        ),
        FlowToneExample(
            id: "night-drift",
            title: "Night Drift",
            subtitle: "5 min delta wind-down",
            settings: .standard(for: FlowTonePreset.sleep, durationMinutes: 5)
        )
    ]
}
