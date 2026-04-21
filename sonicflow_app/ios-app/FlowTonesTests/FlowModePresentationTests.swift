import XCTest
@testable import SonicFlow
import FlowTonesCore

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
    }
}
