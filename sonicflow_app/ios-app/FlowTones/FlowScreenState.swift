import FlowTonesCore
import Foundation

struct FlowScreenState: Equatable {
    let statusLabel: String
    let transportLabel: String
    let selectedMode: FlowMode
    let durationLabel: String
    let selectedFileLabel: String
    let ambientMixValue: Double
    let pulseDepthValue: Double
    let showsAdvancedControls: Bool

    init(
        isPlaying: Bool,
        mode: FlowMode,
        settings: FlowToneSettings,
        selectedFileName: String?
    ) {
        statusLabel = isPlaying ? "Active" : "Off"
        transportLabel = isPlaying ? "Pause" : "Play"
        selectedMode = mode
        durationLabel = "\(settings.durationMinutes) min"
        selectedFileLabel = selectedFileName ?? "No file selected"
        ambientMixValue = settings.ambientMix
        pulseDepthValue = settings.pulseDepth
        showsAdvancedControls = true
    }
}
