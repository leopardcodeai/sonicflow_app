import XCTest
import SonicFlowCore

final class SonicFlowUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAppLaunchesAndShowsModeCards() {
        let focusCard = app.buttons[DesignLabels.Accessibility.modeCardFocus]
        XCTAssertTrue(focusCard.waitForExistence(timeout: 10))
    }

    func testModeCardCanBeTapped() {
        let focusCard = app.buttons[DesignLabels.Accessibility.modeCardFocus]
        XCTAssertTrue(focusCard.waitForExistence(timeout: 10))
        focusCard.tap()
    }

    func testPlayPauseButtonToggles() {
        let playButton = app.buttons[DesignLabels.Accessibility.playButton]
        XCTAssertTrue(playButton.waitForExistence(timeout: 10))
        playButton.tap()

        let pauseButton = app.buttons[DesignLabels.Accessibility.pauseButton]
        XCTAssertTrue(pauseButton.waitForExistence(timeout: 5))
    }

    func testTimerSheetOpens() {
        let timerButton = app.buttons[DesignLabels.Accessibility.timerButton]
        XCTAssertTrue(timerButton.waitForExistence(timeout: 10))
        timerButton.tap()

        let closeTimer = app.buttons[DesignLabels.Accessibility.closeTimer]
        XCTAssertTrue(closeTimer.waitForExistence(timeout: 5))
    }
}
