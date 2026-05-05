import XCTest
@testable import SonicFlow
import SonicFlowCore

final class FlowScreenStateTests: XCTestCase {
    func testAppShellTabsMatchPrimaryNavigationOrder() {
        XCTAssertEqual(SonicFlowTab.allCases, [.home, .library, .stats, .me])
        XCTAssertEqual(SonicFlowTab.allCases.map(\.title), ["Home", "Library", "Stats", "Me"])
        XCTAssertEqual(SonicFlowTab.allCases.map(\.systemImage), ["sparkles", "square.grid.2x2", "chart.bar.xaxis", "person.crop.circle"])
    }

    func testLibrarySearchFiltersCuratedGridByTitleSubtitleAndMode() {
        let allSessions = LibrarySession.curated

        XCTAssertEqual(allSessions.count, 6)
        XCTAssertEqual(LibrarySession.filtered("sleep", in: allSessions).map(\.title), ["Night Drift"])
        XCTAssertEqual(LibrarySession.filtered("theta", in: allSessions).map(\.title), ["Temple Theta"])
        XCTAssertEqual(LibrarySession.filtered("", in: allSessions).count, 6)
    }

    func testTimerOptionsExposeDialDurationsAndLabels() {
        XCTAssertEqual(TimerDialOption.allCases.map(\.minutes), [5, 10, 20, 25, 45, 60])
        XCTAssertEqual(TimerDialOption.twentyFive.label, "25 min")
    }

    func testOnboardingStateUsesLocalizedCopy() {
        XCTAssertEqual(OnboardingPanelState(language: .english).headline, "Tune the room before you begin")
        XCTAssertEqual(OnboardingPanelState(language: .german).primaryActionTitle, "Starten")
    }

    func testSystemAffordanceStubsDescribeExternalSurfaces() {
        XCTAssertEqual(SystemAffordanceStub.allCases, [.lockScreen, .dynamicIsland, .shortcuts])
        XCTAssertEqual(SystemAffordanceStub.dynamicIsland.symbolName, "capsule.portrait")
        XCTAssertTrue(SystemAffordanceStub.shortcuts.detail.contains("App Shortcuts"))
    }

    func testShortcutRequestsRoundTripThroughUserDefaults() {
        let defaults = UserDefaults(suiteName: "sonicflow-shortcut-test")!
        defaults.removePersistentDomain(forName: "sonicflow-shortcut-test")
        let request = SonicFlowShortcutRequest(action: .start, mode: "sleep", durationMinutes: 45)

        SonicFlowShortcutRequestStore.save(request, defaults: defaults)

        XCTAssertEqual(SonicFlowShortcutRequestStore.consume(defaults: defaults), request)
        XCTAssertNil(SonicFlowShortcutRequestStore.consume(defaults: defaults))
        XCTAssertEqual(request.flowMode, .sleep)
    }

    func testLiveActivityStateClampsRemainingMinutes() {
        if #available(iOS 16.2, *) {
            let state = SonicFlowLiveActivityAttributes.ContentState.playback(
                isPlaying: true,
                modeName: "Focus",
                durationMinutes: 0
            )

            XCTAssertEqual(state.status, "Active")
            XCTAssertEqual(state.remainingMinutes, 1)
            XCTAssertTrue(state.isPlaying)
        }
    }

    func testDefaultFlowStateShowsAdvancedControls() {
        let state = FlowScreenState(
            isPlaying: false,
            mode: FlowMode.flow,
            settings: .standard(for: SonicFlowPreset.flow, durationMinutes: 25)
        )

        XCTAssertEqual(state.statusLabel, "Off")
        XCTAssertEqual(state.transportLabel, "Play")
        XCTAssertEqual(state.selectedMode, FlowMode.flow)
        XCTAssertEqual(state.durationLabel, "25 min")
        XCTAssertTrue(state.showsAdvancedControls)
    }

    func testActiveStateShowsPauseTransport() {
        let state = FlowScreenState(
            isPlaying: true,
            mode: FlowMode.sleep,
            settings: .standard(for: SonicFlowPreset.sleep, durationMinutes: 5)
        )

        XCTAssertEqual(state.statusLabel, "Active")
        XCTAssertEqual(state.transportLabel, "Pause")
    }

    func testHomeDesignPolicyKeepsLeopardAndGlassButtons() {
        XCTAssertTrue(HomeDesignPolicy.usesLeopardBackdrop)
        XCTAssertEqual(HomeDesignPolicy.homeBackdropScrimOpacity, 0.18, accuracy: 0.001)
        XCTAssertEqual(HomeDesignPolicy.primaryActionButtonHeight, 44)
        XCTAssertEqual(HomeDesignPolicy.compactIconButtonSize, 42)
        XCTAssertTrue(HomeDesignPolicy.constrainsHomeContentToViewport)
        XCTAssertTrue(HomeDesignPolicy.usesLayoutNeutralLeopardBackdrop)
        XCTAssertEqual(HomeDesignPolicy.homeVerticalOuterPadding, 0)
        XCTAssertEqual(HomeDesignPolicy.miniPlayerVerticalInsetPadding, 0)
        XCTAssertEqual(HomeDesignPolicy.miniPlayerTabBarClearance, 64)
    }
}
