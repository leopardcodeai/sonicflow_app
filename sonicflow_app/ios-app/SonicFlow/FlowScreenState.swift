import SonicFlowCore
import Foundation

struct FlowScreenState: Equatable {
    let statusLabel: String
    let transportLabel: String
    let selectedMode: FlowMode
    let durationLabel: String
    let selectedFileLabel: String
    let overlayModeTitle: String
    let overlayModeStatus: String
    let ambientMixValue: Double
    let pulseDepthValue: Double
    let showsAdvancedControls: Bool

    init(
        isPlaying: Bool,
        mode: FlowMode,
        settings: SonicFlowSettings,
        selectedFileName: String?
    ) {
        statusLabel = isPlaying ? "Active" : "Off"
        transportLabel = isPlaying ? "Pause" : "Play"
        selectedMode = mode
        durationLabel = "\(settings.durationMinutes) min"
        selectedFileLabel = selectedFileName ?? "No file selected"
        overlayModeTitle = "Overlay Mode"
        overlayModeStatus = "iOS can layer SonicFlow under picked files. Spotify and YouTube system overlay are unavailable on iOS."
        ambientMixValue = settings.ambientMix
        pulseDepthValue = settings.pulseDepth
        showsAdvancedControls = true
    }
}
