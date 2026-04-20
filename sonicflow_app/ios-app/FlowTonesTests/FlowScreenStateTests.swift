import XCTest
@testable import SonicFlow
import FlowTonesCore

final class FlowScreenStateTests: XCTestCase {
    func testDefaultFlowStateShowsAdvancedControls() {
        let state = FlowScreenState(
            isPlaying: false,
            mode: .flow,
            settings: .standard(for: .flow, durationMinutes: 25),
            selectedFileName: nil
        )

        XCTAssertEqual(state.statusLabel, "Off")
        XCTAssertEqual(state.transportLabel, "Play")
        XCTAssertEqual(state.selectedMode, .flow)
        XCTAssertEqual(state.durationLabel, "25 min")
        XCTAssertTrue(state.showsAdvancedControls)
    }

    func testActiveStatePreservesPickedFileName() {
        let state = FlowScreenState(
            isPlaying: true,
            mode: .sleep,
            settings: .standard(for: .sleep, durationMinutes: 5),
            selectedFileName: "night-rain.m4a"
        )

        XCTAssertEqual(state.statusLabel, "Active")
        XCTAssertEqual(state.transportLabel, "Pause")
        XCTAssertEqual(state.selectedFileLabel, "night-rain.m4a")
    }
}
