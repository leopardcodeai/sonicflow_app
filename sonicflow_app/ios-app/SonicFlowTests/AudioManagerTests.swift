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

    func testDownloadedSessionCanStartWithoutNetwork() {
        let audioManager = AudioManager()
        audioManager.currentMode = .sleep
        audioManager.updateDuration(40)

        XCTAssertTrue(audioManager.downloadCurrentSession(byteCount: 700_000))
        audioManager.isNetworkAvailable = false
        audioManager.togglePlayback()

        XCTAssertTrue(audioManager.isPlaying)
        XCTAssertEqual(audioManager.offlineAvailability, .downloaded)
        XCTAssertEqual(audioManager.activeOfflineAssetId, audioManager.sessionSettings.cacheKey)
    }

    func testDeletingCurrentSessionDownloadClearsOfflineAvailability() {
        let audioManager = AudioManager()

        XCTAssertTrue(audioManager.downloadCurrentSession(byteCount: 700_000))
        XCTAssertEqual(audioManager.offlineAvailability, .downloaded)

        audioManager.deleteCurrentSessionDownload()

        XCTAssertEqual(audioManager.offlineAvailability, .notDownloaded)
        XCTAssertNil(audioManager.activeOfflineAssetId)
    }
}
