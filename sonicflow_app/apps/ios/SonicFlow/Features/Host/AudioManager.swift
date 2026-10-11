import AVFoundation
import SonicFlowCore
import Foundation

final class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var isNetworkAvailable = true
    @Published private(set) var playbackErrorMessage: String?
    @Published private(set) var activeOfflineAssetId: String?
    @Published private(set) var offlineLibrary = OfflineSessionLibrary(storageLimitBytes: 1_000_000)
    @Published var currentMode: FlowMode = .focus {
        didSet {
            sessionSettings = sessionSettings.applyingPreset(
                SonicFlowPreset(mode: currentMode),
                preserveDuration: true
            )
            refreshOfflineAvailability()
            syncSystemSurfaces()
        }
    }
    @Published var sessionSettings = SonicFlowSettings.standard(for: SonicFlowPreset.focus) {
        didSet {
            refreshOfflineAvailability()
            syncSystemSurfaces()
        }
    }
    @Published private(set) var offlineAvailability: OfflineSessionAvailability = .notDownloaded
    @Published var beatVolume: Double = 0.15 {
        didSet {
            beatMixerNode.volume = Float(beatVolume)
        }
    }

    private let beatEngine = BeatEngine()
    private let engine: AVAudioEngine
    private let musicNode = AVAudioPlayerNode()
    private let beatMixerNode = AVAudioMixerNode()
    private let liveActivityBridge = SonicFlowLiveActivityBridge()
    private let startEngineOverride: (() throws -> Void)?
    private let pauseEngineOverride: (() -> Void)?
    private var beatSourceNode: AVAudioSourceNode?

    init(
        engine: AVAudioEngine = AVAudioEngine(),
        startEngineOverride: (() throws -> Void)? = nil,
        pauseEngineOverride: (() -> Void)? = nil
    ) {
        self.engine = engine
        self.startEngineOverride = startEngineOverride
        self.pauseEngineOverride = pauseEngineOverride
        configureSession()
        configureEngine()
    }

    func togglePlayback() {
        if isPlaying {
            stopPlayback()
        } else {
            startPlayback()
        }
    }

    func updateDuration(_ minutes: Int) {
        sessionSettings.durationMinutes = max(5, min(60, minutes))
    }

    func updateAmbientMix(_ value: Double) {
        sessionSettings.ambientMix = value
    }

    func updatePulseDepth(_ value: Double) {
        sessionSettings.pulseDepth = value
    }

    func applyExample(_ example: SonicFlowExample) {
        sessionSettings = example.settings
        currentMode = example.settings.mode
    }

    func consumeShortcutRequestIfNeeded() {
        guard let request = SonicFlowShortcutRequestStore.consume() else {
            return
        }

        switch request.action {
        case .start:
            currentMode = request.flowMode
            updateDuration(request.durationMinutes)
            if !isPlaying {
                togglePlayback()
            } else {
                syncSystemSurfaces()
            }
        case .pause:
            if isPlaying {
                togglePlayback()
            }
        }
    }

    @discardableResult
    func downloadCurrentSession(byteCount: Int = 700_000) -> Bool {
        let stored = offlineLibrary.store(
            OfflineSessionAsset(settings: sessionSettings, byteCount: byteCount)
        )
        refreshOfflineAvailability()
        return stored
    }

    func deleteCurrentSessionDownload() {
        offlineLibrary.delete(settings: sessionSettings)
        activeOfflineAssetId = nil
        refreshOfflineAvailability()
    }

    private func refreshOfflineAvailability() {
        offlineAvailability = offlineLibrary.availability(for: sessionSettings)
    }

    private func syncSystemSurfaces() {
        liveActivityBridge.sync(
            isPlaying: isPlaying,
            modeName: currentMode.displayName,
            durationMinutes: sessionSettings.durationMinutes
        )
    }

    func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetoothA2DP])
        try? session.setActive(true)
    }

    private func configureEngine() {
        engine.attach(musicNode)
        engine.attach(beatMixerNode)

        let format = engine.outputNode.outputFormat(forBus: 0)
        let sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self else { return noErr }
            let frames = Int(frameCount)
            let pcm = self.renderBeatFrames(frameCount: frames, sampleRate: format.sampleRate)
            let buffers = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for channelIndex in 0..<buffers.count {
                let target = buffers[channelIndex].mData?.assumingMemoryBound(to: Float.self)
                for frame in 0..<frames {
                    target?[frame] = pcm[(frame * 2) + min(channelIndex, 1)] * Float(self.beatVolume)
                }
            }

            return noErr
        }

        beatSourceNode = sourceNode
        engine.attach(sourceNode)
        engine.connect(musicNode, to: engine.mainMixerNode, format: format)
        engine.connect(sourceNode, to: beatMixerNode, format: format)
        engine.connect(beatMixerNode, to: engine.mainMixerNode, format: format)
        beatMixerNode.volume = Float(beatVolume)
        engine.prepare()
    }

    private func startPlayback() {
        playbackErrorMessage = nil
        configureSession()

        do {
            try startAudioEngineIfNeeded()
            if !isNetworkAvailable && offlineLibrary.canStartOffline(settings: sessionSettings) {
                activeOfflineAssetId = sessionSettings.cacheKey
            }
            isPlaying = true
        } catch {
            activeOfflineAssetId = nil
            isPlaying = false
            playbackErrorMessage = DesignLabels.text(.audioEngineError, language: .english)
        }

        syncSystemSurfaces()
    }

    private func stopPlayback() {
        activeOfflineAssetId = nil
        pauseAudioEngine()
        isPlaying = false
        syncSystemSurfaces()
    }

    private func startAudioEngineIfNeeded() throws {
        if let startEngineOverride {
            try startEngineOverride()
            return
        }

        if !engine.isRunning {
            try engine.start()
        }
    }

    private func pauseAudioEngine() {
        if let pauseEngineOverride {
            pauseEngineOverride()
            return
        }

        if engine.isRunning {
            engine.pause()
        }
    }

    private func renderBeatFrames(frameCount: Int, sampleRate: Double) -> [Float] {
        guard let buffer = try? beatEngine.generate(mode: currentMode, durationSeconds: Double(frameCount) / sampleRate, sampleRate: sampleRate),
              let left = buffer.floatChannelData?[0],
              let right = buffer.floatChannelData?[1] else {
            return Array(repeating: 0, count: frameCount * 2)
        }

        var interleaved = Array(repeating: Float.zero, count: frameCount * 2)
        for frame in 0..<frameCount {
            interleaved[frame * 2] = left[frame]
            interleaved[(frame * 2) + 1] = right[frame]
        }
        return interleaved
    }
}
