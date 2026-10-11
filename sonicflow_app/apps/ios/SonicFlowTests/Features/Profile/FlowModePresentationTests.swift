import XCTest
@testable import SonicFlow
import SonicFlowCore

final class FlowModePresentationTests: XCTestCase {
    func testFlowModePresentationValuesMatchDesignSpec() {
        XCTAssertEqual(FlowMode.focus.displayName, "Focus")
        XCTAssertEqual(FlowMode.focus.accentColorHex, "#378ADD")
        XCTAssertEqual(FlowMode.focus.shortDescription, "Gamma focus boost")
        XCTAssertEqual(FlowMode.flow.displayName, "Flow")
        XCTAssertEqual(FlowMode.flow.accentColorHex, "#7F77DD")
        XCTAssertEqual(FlowMode.flow.shortDescription, "Alpha concentration")
        XCTAssertEqual(FlowMode.meditation.displayName, "Meditation")
        XCTAssertEqual(FlowMode.meditation.accentColorHex, "#1D9E75")
        XCTAssertEqual(FlowMode.meditation.shortDescription, "Theta calm depth")
        XCTAssertEqual(FlowMode.sleep.displayName, "Sleep")
        XCTAssertEqual(FlowMode.sleep.accentColorHex, "#534AB7")
        XCTAssertEqual(FlowMode.sleep.shortDescription, "Delta deep rest")
        XCTAssertEqual(FlowMode.focus.ritualTitle, "Focus Ritual")
        XCTAssertEqual(FlowMode.flow.ritualTitle, "Flow Ritual")
        XCTAssertEqual(FlowMode.meditation.ritualTitle, "Meditation Ritual")
        XCTAssertEqual(FlowMode.sleep.ritualTitle, "Sleep Ritual")
        XCTAssertEqual(FlowMode.focus.ritualSummary, "Gamma clarity for deep work and bright attention.")
        XCTAssertEqual(FlowMode.flow.ritualSummary, "Alpha momentum for creative rhythm and smooth concentration.")
        XCTAssertEqual(FlowMode.meditation.ritualSummary, "Theta spaciousness for breath, stillness, and recovery.")
        XCTAssertEqual(FlowMode.sleep.ritualSummary, "Delta softness for slow unwinding and rest.")
    }
}
