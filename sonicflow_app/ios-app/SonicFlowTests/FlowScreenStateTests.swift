import XCTest
@testable import SonicFlow
import SonicFlowCore

final class FlowScreenStateTests: XCTestCase {
    func testDefaultFlowStateShowsAdvancedControls() {
        let state = FlowScreenState(
            isPlaying: false,
            mode: FlowMode.flow,
            settings: .standard(for: SonicFlowPreset.flow, durationMinutes: 25),
            selectedFileName: nil
        )

        XCTAssertEqual(state.statusLabel, "Off")
        XCTAssertEqual(state.transportLabel, "Play")
        XCTAssertEqual(state.selectedMode, FlowMode.flow)
        XCTAssertEqual(state.durationLabel, "25 min")
        XCTAssertEqual(state.overlayModeTitle, "Overlay Mode")
        XCTAssertEqual(
            state.overlayModeStatus,
            "iOS can layer SonicFlow under picked files. Spotify and YouTube system overlay are unavailable on iOS."
        )
        XCTAssertTrue(state.showsAdvancedControls)
    }

    func testActiveStatePreservesPickedFileName() {
        let state = FlowScreenState(
            isPlaying: true,
            mode: FlowMode.sleep,
            settings: .standard(for: SonicFlowPreset.sleep, durationMinutes: 5),
            selectedFileName: "night-rain.m4a"
        )

        XCTAssertEqual(state.statusLabel, "Active")
        XCTAssertEqual(state.transportLabel, "Pause")
        XCTAssertEqual(state.selectedFileLabel, "night-rain.m4a")
    }
}
