import XCTest
@testable import SonicFlow

final class AudioManagerTests: XCTestCase {
    func testInitialStateUsesFocusModeAndQuietBeatLayer() {
        let audioManager = AudioManager()

        XCTAssertEqual(audioManager.currentMode, .focus)
        XCTAssertEqual(audioManager.beatVolume, 0.15, accuracy: 0.0001)
        XCTAssertFalse(audioManager.isPlaying)
    }

    func testTogglePlaybackFlipsPlayState() {
        let audioManager = AudioManager()

        audioManager.togglePlayback()
        XCTAssertTrue(audioManager.isPlaying)

        audioManager.togglePlayback()
        XCTAssertFalse(audioManager.isPlaying)
    }
}
