import XCTest
@testable import SonicFlow
import FlowTonesCore

final class FlowToneSettingsTests: XCTestCase {
    func testStandardSettingsUseFlowPresetDefaults() {
        let settings = FlowToneSettings.standard(for: FlowTonePreset.flow, durationMinutes: 5)

        XCTAssertEqual(settings.mode, FlowMode.flow)
        XCTAssertEqual(settings.preset, FlowTonePreset.flow)
        XCTAssertEqual(settings.durationMinutes, 5)
        XCTAssertEqual(settings.beatFrequencyHz, 10, accuracy: 0.0001)
        XCTAssertEqual(settings.carrierFrequencyHz, 200, accuracy: 0.0001)
        XCTAssertEqual(settings.ambientMix, 0.55, accuracy: 0.0001)
        XCTAssertEqual(settings.pulseDepth, 0.78, accuracy: 0.0001)
    }

    func testApplyingPresetPreservesDuration() {
        let settings = FlowToneSettings.standard(for: FlowTonePreset.focus, durationMinutes: 35)
        let updated = settings.applyingPreset(FlowTonePreset.sleep)

        XCTAssertEqual(updated.preset, FlowTonePreset.sleep)
        XCTAssertEqual(updated.mode, FlowMode.sleep)
        XCTAssertEqual(updated.durationMinutes, 35)
        XCTAssertEqual(updated.ambientMix, 0.78, accuracy: 0.0001)
    }

    func testCacheKeyIsStableForEquivalentSettings() {
        let lhs = FlowToneSettings.standard(for: FlowTonePreset.meditation, durationMinutes: 20)
        let rhs = FlowToneSettings(
            preset: FlowTonePreset.meditation,
            durationMinutes: 20,
            beatFrequencyHz: 6,
            carrierFrequencyHz: 180,
            ambientMix: 0.68,
            pulseDepth: 0.62
        )

        XCTAssertEqual(lhs.cacheKey, rhs.cacheKey)
    }

    func testBrainFmParitySessionTaxonomyMapsActivitiesAndTimers() {
        XCTAssertEqual(SessionProductMode.allCases, [.focus, .relax, .sleep, .meditate])
        XCTAssertEqual(SessionActivity.allCases.count, 15)

        XCTAssertEqual(SessionActivity.creativeFlow.productMode, .focus)
        XCTAssertEqual(SessionActivity.creativeFlow.engineMode, .flow)
        XCTAssertEqual(SessionActivity.creativeFlow.defaultTimer, .pomodoro)
        XCTAssertEqual(SessionActivity.windDown.productMode, .sleep)
        XCTAssertEqual(SessionActivity.windDown.defaultTimer, .infiniteSleep)
        XCTAssertEqual(SessionTimer.pomodoro.durationMinutes, 25)
        XCTAssertNil(SessionTimer.infiniteSleep.durationMinutes)
    }
}
