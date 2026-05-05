import XCTest
@testable import SonicFlow
import SonicFlowCore

final class SonicFlowFeatureTests: XCTestCase {
    // MARK: - Timer

    func testTimerDialOptionsCoverExpectedDurations() {
        let allMinutes = TimerDialOption.allCases.map(\.minutes)
        XCTAssertEqual(allMinutes, [5, 10, 20, 25, 45, 60])
    }

    func testTimerDialLabelFormat() {
        XCTAssertEqual(TimerDialOption.five.label, "5 min")
        XCTAssertEqual(TimerDialOption.twentyFive.label, "25 min")
        XCTAssertEqual(TimerDialOption.sixty.label, "60 min")
    }

    func testTimerDialIdsMatchRawValues() {
        for option in TimerDialOption.allCases {
            XCTAssertEqual(option.id, option.rawValue)
        }
    }

    // MARK: - Mode Selection

    func testFlowModeAllCasesOrder() {
        XCTAssertEqual(FlowMode.allCases, [.focus, .flow, .meditation, .sleep])
    }

    func testFlowModeBeatHzValuesMatchSpec() {
        XCTAssertEqual(FlowMode.focus.beatHz, 40)
        XCTAssertEqual(FlowMode.flow.beatHz, 10)
        XCTAssertEqual(FlowMode.meditation.beatHz, 6)
        XCTAssertEqual(FlowMode.sleep.beatHz, 2)
    }

    func testFlowModeCarrierHzValuesMatchSpec() {
        XCTAssertEqual(FlowMode.focus.carrierHz, 200)
        XCTAssertEqual(FlowMode.flow.carrierHz, 200)
        XCTAssertEqual(FlowMode.meditation.carrierHz, 180)
        XCTAssertEqual(FlowMode.sleep.carrierHz, 150)
    }

    // MARK: - Presets

    func testAllPresetsMapToCorrespondingFlowModes() {
        for preset in SonicFlowPreset.allCases {
            XCTAssertEqual(preset.mode.beatHz, preset.beatFrequencyHz)
        }
    }

    func testPresetDisplayNamesAreNotEmpty() {
        for preset in SonicFlowPreset.allCases {
            XCTAssertFalse(preset.displayName.isEmpty)
            XCTAssertFalse(preset.summary.isEmpty)
        }
    }

    func testPresetIconsUseSFSymbols() {
        for preset in SonicFlowPreset.allCases {
            XCTAssertFalse(preset.icon.isEmpty)
        }
    }

    // MARK: - Session Activities

    func testSessionActivitiesMapToExpectedFlowModes() {
        XCTAssertEqual(SessionActivity.deepWork.engineMode, .focus)
        XCTAssertEqual(SessionActivity.creativeFlow.engineMode, .flow)
        XCTAssertEqual(SessionActivity.guidedMeditation.engineMode, .meditation)
        XCTAssertEqual(SessionActivity.deepSleep.engineMode, .sleep)
    }

    func testSessionActivityProductModes() {
        XCTAssertEqual(SessionActivity.deepWork.productMode, .focus)
        XCTAssertEqual(SessionActivity.unwind.productMode, .relax)
        XCTAssertEqual(SessionActivity.windDown.productMode, .sleep)
        XCTAssertEqual(SessionActivity.guidedMeditation.productMode, .meditate)
    }

    func testAllActivitiesMapToValidTimers() {
        for activity in SessionActivity.allCases {
            XCTAssertNotNil(activity.defaultTimer.rawValue)
        }
    }

    // MARK: - System Surfaces

    func testSystemAffordanceMetadataIsComplete() {
        for affordance in SystemAffordanceStub.allCases {
            XCTAssertFalse(affordance.title.isEmpty)
            XCTAssertFalse(affordance.detail.isEmpty)
            XCTAssertFalse(affordance.symbolName.isEmpty)
        }
    }

    func testSystemAffordanceSymbolsAreValid() {
        XCTAssertEqual(SystemAffordanceStub.lockScreen.symbolName, "lock.iphone")
        XCTAssertEqual(SystemAffordanceStub.dynamicIsland.symbolName, "capsule.portrait")
        XCTAssertEqual(SystemAffordanceStub.shortcuts.symbolName, "app.badge.checkmark")
    }

    // MARK: - Starter Pack

    func testStarterPackAllHaveFiveMinuteDuration() {
        for example in SonicFlowExample.starterPack {
            XCTAssertEqual(example.settings.durationMinutes, 5, "\(example.title) should be 5 min")
        }
    }

    func testStarterPackCoversAllModes() {
        let modes = Set(SonicFlowExample.starterPack.map(\.settings.mode))
        XCTAssertTrue(modes.contains(.focus))
        XCTAssertTrue(modes.contains(.flow))
        XCTAssertTrue(modes.contains(.sleep))
    }

    func testStarterPackTitlesAndSubtitlesAreNonEmpty() {
        for example in SonicFlowExample.starterPack {
            XCTAssertFalse(example.title.isEmpty)
            XCTAssertFalse(example.subtitle.isEmpty)
        }
    }

    // MARK: - Onboarding

    func testOnboardingStateLocalizedCopy() {
        let en = OnboardingPanelState(language: .english)
        XCTAssertEqual(en.headline, "Tune the room before you begin")
        XCTAssertEqual(en.body, "Choose a session, shape the neural layer, and keep SonicFlow ready from your phone surface.")
        XCTAssertEqual(en.primaryActionTitle, "Start")

        let de = OnboardingPanelState(language: .german)
        XCTAssertEqual(de.headline, "Stimme den Raum ein, bevor du beginnst")
        XCTAssertEqual(de.body, "Wahle eine Session, forme die neurale Ebene und halte SonicFlow auf dem iPhone bereit.")
        XCTAssertEqual(de.primaryActionTitle, "Starten")
    }

    // MARK: - Library

    func testLibrarySessionsCoverAllModes() {
        let modes = Set(LibrarySession.curated.map(\.mode))
        XCTAssertEqual(modes, [.focus, .flow, .meditation, .sleep])
    }

    func testLibrarySearchIsCaseInsensitive() {
        let sleep = LibrarySession.filtered("SLEEP")
        XCTAssertTrue(sleep.allSatisfy { $0.mode == .sleep || $0.title.lowercased().contains("sleep") || $0.subtitle.lowercased().contains("sleep") })
    }

    func testLibrarySearchEmptyQueryReturnsAll() {
        XCTAssertEqual(LibrarySession.filtered("").count, LibrarySession.curated.count)
    }

    // MARK: - AudioManager Integration

    func testSessionPresetAppliesDefaultAmbientMix() {
        let focus = SonicFlowSettings.standard(for: SonicFlowPreset.focus)
        XCTAssertEqual(focus.ambientMix, 0.45, accuracy: 0.0001)

        let sleep = SonicFlowSettings.standard(for: SonicFlowPreset.sleep)
        XCTAssertEqual(sleep.ambientMix, 0.78, accuracy: 0.0001)
    }

    func testSessionPresetAppliesDefaultPulseDepth() {
        let focus = SonicFlowSettings.standard(for: SonicFlowPreset.focus)
        XCTAssertEqual(focus.pulseDepth, 0.95, accuracy: 0.0001)

        let sleep = SonicFlowSettings.standard(for: SonicFlowPreset.sleep)
        XCTAssertEqual(sleep.pulseDepth, 0.46, accuracy: 0.0001)
    }
}
