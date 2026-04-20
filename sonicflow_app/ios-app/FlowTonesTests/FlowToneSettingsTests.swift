import XCTest
@testable import SonicFlow
import FlowTonesCore

final class FlowToneSettingsTests: XCTestCase {
    func testStandardSettingsUseFlowPresetDefaults() {
        let settings = FlowToneSettings.standard(for: .flow, durationMinutes: 5)

        XCTAssertEqual(settings.mode, .flow)
        XCTAssertEqual(settings.durationMinutes, 5)
        XCTAssertEqual(settings.ambientMix, 0.55, accuracy: 0.0001)
        XCTAssertEqual(settings.pulseDepth, 0.78, accuracy: 0.0001)
    }
}
