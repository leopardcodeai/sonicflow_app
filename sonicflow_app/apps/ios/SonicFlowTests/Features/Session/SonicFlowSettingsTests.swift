import XCTest
@testable import SonicFlow
import SonicFlowCore

final class SonicFlowSettingsTests: XCTestCase {
    func testStandardSettingsUseFlowPresetDefaults() {
        let settings = SonicFlowSettings.standard(for: SonicFlowPreset.flow, durationMinutes: 5)

        XCTAssertEqual(settings.mode, FlowMode.flow)
        XCTAssertEqual(settings.preset, SonicFlowPreset.flow)
        XCTAssertEqual(settings.durationMinutes, 5)
        XCTAssertEqual(settings.beatFrequencyHz, 10, accuracy: 0.0001)
        XCTAssertEqual(settings.carrierFrequencyHz, 200, accuracy: 0.0001)
        XCTAssertEqual(settings.ambientMix, 0.55, accuracy: 0.0001)
        XCTAssertEqual(settings.pulseDepth, 0.78, accuracy: 0.0001)
    }

    func testApplyingPresetPreservesDuration() {
        let settings = SonicFlowSettings.standard(for: SonicFlowPreset.focus, durationMinutes: 35)
        let updated = settings.applyingPreset(SonicFlowPreset.sleep)

        XCTAssertEqual(updated.preset, SonicFlowPreset.sleep)
        XCTAssertEqual(updated.mode, FlowMode.sleep)
        XCTAssertEqual(updated.durationMinutes, 35)
        XCTAssertEqual(updated.ambientMix, 0.78, accuracy: 0.0001)
    }

    func testCacheKeyIsStableForEquivalentSettings() {
        let lhs = SonicFlowSettings.standard(for: SonicFlowPreset.meditation, durationMinutes: 20)
        let rhs = SonicFlowSettings(
            preset: SonicFlowPreset.meditation,
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

    func testOfflineSessionLibraryTracksDownloadDeleteAndOfflineAvailability() {
        let settings = SonicFlowSettings.standard(for: SonicFlowPreset.sleep, durationMinutes: 45)
        let asset = OfflineSessionAsset(settings: settings, byteCount: 720_000)
        var library = OfflineSessionLibrary(storageLimitBytes: 1_500_000)

        XCTAssertEqual(asset.id, settings.cacheKey)
        XCTAssertEqual(library.availability(for: settings), .notDownloaded)

        XCTAssertTrue(library.store(asset))
        XCTAssertEqual(library.availability(for: settings), .downloaded)
        XCTAssertTrue(library.canStartOffline(settings: settings))

        library.delete(settings: settings)
        XCTAssertEqual(library.availability(for: settings), .notDownloaded)
        XCTAssertFalse(library.canStartOffline(settings: settings))
    }

    func testOfflineSessionLibraryRejectsDownloadsOverQuota() {
        let first = SonicFlowSettings.standard(for: SonicFlowPreset.focus, durationMinutes: 25)
        let second = SonicFlowSettings.standard(for: SonicFlowPreset.meditation, durationMinutes: 25)
        var library = OfflineSessionLibrary(storageLimitBytes: 1_000_000)

        XCTAssertTrue(library.store(OfflineSessionAsset(settings: first, byteCount: 650_000)))
        XCTAssertFalse(library.store(OfflineSessionAsset(settings: second, byteCount: 500_000)))
        XCTAssertEqual(library.availability(for: second), .storageFull)
        XCTAssertEqual(library.usedBytes, 650_000)
    }
}
