import XCTest
import AVFoundation
import SonicFlowCore
@testable import SonicFlow

final class AudioManagerTests: XCTestCase {
    private enum TestAudioError: Error {
        case failedToStart
    }

    func testInitialStateUsesFocusModeAndQuietBeatLayer() {
        let audioManager = AudioManager()

        XCTAssertEqual(audioManager.currentMode, .focus)
        XCTAssertEqual(audioManager.beatVolume, 0.15, accuracy: 0.0001)
        XCTAssertFalse(audioManager.isPlaying)
    }

    func testTogglePlaybackFlipsPlayState() {
        var startCount = 0
        var pauseCount = 0
        let audioManager = AudioManager(
            startEngineOverride: {
                startCount += 1
            },
            pauseEngineOverride: {
                pauseCount += 1
            }
        )

        audioManager.togglePlayback()
        XCTAssertTrue(audioManager.isPlaying)
        XCTAssertEqual(startCount, 1)
        XCTAssertEqual(pauseCount, 0)

        audioManager.togglePlayback()
        XCTAssertFalse(audioManager.isPlaying)
        XCTAssertEqual(startCount, 1)
        XCTAssertEqual(pauseCount, 1)
    }

    func testPlaybackStaysStoppedWhenAudioEngineFails() {
        let audioManager = AudioManager(
            startEngineOverride: {
                throw TestAudioError.failedToStart
            }
        )

        audioManager.togglePlayback()

        XCTAssertFalse(audioManager.isPlaying)
        XCTAssertEqual(audioManager.playbackErrorMessage, DesignLabels.text(.audioEngineError, language: .english))
    }

    func testDownloadedSessionCanStartWithoutNetwork() {
        let audioManager = AudioManager(startEngineOverride: {})
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

    func testConfigureSessionSetsAudioCategory() throws {
        let audioManager = AudioManager()

        audioManager.configureSession()

        let session = AVAudioSession.sharedInstance()
        XCTAssertEqual(session.category, .playback)
        XCTAssertTrue(session.categoryOptions.contains(.mixWithOthers))
        XCTAssertTrue(session.categoryOptions.contains(.allowBluetoothA2DP))
    }

    func testEngineStartsWithRealAudioEngine() throws {
        let audioManager = AudioManager()

        audioManager.togglePlayback()

        XCTAssertTrue(audioManager.isPlaying)
        XCTAssertNil(audioManager.playbackErrorMessage)

        audioManager.togglePlayback()
        XCTAssertFalse(audioManager.isPlaying)
    }

    func testDurationClampsToValidRange() {
        let audioManager = AudioManager()

        audioManager.updateDuration(0)
        XCTAssertEqual(audioManager.sessionSettings.durationMinutes, 5)

        audioManager.updateDuration(100)
        XCTAssertEqual(audioManager.sessionSettings.durationMinutes, 60)

        audioManager.updateDuration(25)
        XCTAssertEqual(audioManager.sessionSettings.durationMinutes, 25)
    }

    func testModeSwitchUpdatesSessionPreset() {
        let audioManager = AudioManager()

        audioManager.currentMode = .sleep
        XCTAssertEqual(audioManager.sessionSettings.preset, .sleep)
        XCTAssertEqual(audioManager.sessionSettings.mode, .sleep)
        XCTAssertEqual(audioManager.sessionSettings.beatFrequencyHz, 2, accuracy: 0.0001)
        XCTAssertEqual(audioManager.sessionSettings.pulseDepth, 0.46, accuracy: 0.0001)

        audioManager.currentMode = .focus
        XCTAssertEqual(audioManager.sessionSettings.preset, .focus)
        XCTAssertEqual(audioManager.sessionSettings.pulseDepth, 0.95, accuracy: 0.0001)
    }

    func testAmbientMixAndPulseDepthUpdate() {
        let audioManager = AudioManager()

        audioManager.updateAmbientMix(0.8)
        XCTAssertEqual(audioManager.sessionSettings.ambientMix, 0.8, accuracy: 0.0001)

        audioManager.updatePulseDepth(0.3)
        XCTAssertEqual(audioManager.sessionSettings.pulseDepth, 0.3, accuracy: 0.0001)
    }
}
