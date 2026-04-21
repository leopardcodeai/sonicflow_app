import AVFoundation
import Combine
import CoreGraphics
import CoreMedia
import Foundation
import ScreenCaptureKit

enum AudioSource: String, CaseIterable {
    case system
    case file
}

enum MacFlowTonePreset: String, CaseIterable, Identifiable {
    case focus
    case flow
    case meditation
    case sleep

    var id: String { rawValue }

    init(mode: FlowMode) {
        switch mode {
        case .focus: self = .focus
        case .flow: self = .flow
        case .meditation: self = .meditation
        case .sleep: self = .sleep
        }
    }

    var mode: FlowMode {
        switch self {
        case .focus: return .focus
        case .flow: return .flow
        case .meditation: return .meditation
        case .sleep: return .sleep
        }
    }

    var displayName: String {
        switch self {
        case .focus: return "Focus"
        case .flow: return "Flow"
        case .meditation: return "Meditation"
        case .sleep: return "Sleep"
        }
    }

    var summary: String {
        switch self {
        case .focus: return "Gamma lift for intense study and deep concentration."
        case .flow: return "Alpha pulse for smooth, creative momentum."
        case .meditation: return "Theta drift for spacious stillness and breathwork."
        case .sleep: return "Delta wash for slow unwinding and soft rest."
        }
    }

    var beatFrequencyHz: Double { mode.beatHz }

    var carrierFrequencyHz: Double {
        switch self {
        case .focus, .flow:
            return 200
        case .meditation:
            return 180
        case .sleep:
            return 150
        }
    }

    var defaultAmbientMix: Double {
        switch self {
        case .focus: return 0.45
        case .flow: return 0.55
        case .meditation: return 0.68
        case .sleep: return 0.78
        }
    }

    var defaultPulseDepth: Double {
        switch self {
        case .focus: return 0.95
        case .flow: return 0.78
        case .meditation: return 0.62
        case .sleep: return 0.46
        }
    }
}

struct MacFlowToneExample: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let preset: MacFlowTonePreset
    let durationMinutes: Int

    static let starterPack: [MacFlowToneExample] = [
        MacFlowToneExample(
            id: "focus-primer",
            title: "Focus Primer",
            subtitle: "5 min gamma warmup",
            preset: .focus,
            durationMinutes: 5
        ),
        MacFlowToneExample(
            id: "flow-reset",
            title: "Flow Reset",
            subtitle: "5 min alpha reset",
            preset: .flow,
            durationMinutes: 5
        ),
        MacFlowToneExample(
            id: "night-drift",
            title: "Night Drift",
            subtitle: "5 min delta wind-down",
            preset: .sleep,
            durationMinutes: 5
        )
    ]
}

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentMode: FlowMode = .focus {
        didSet {
            applyPreset(MacFlowTonePreset(mode: currentMode), preserveDuration: true)
        }
    }
    @Published var beatVolume: Double = 0.15 {
        didSet {
            beatMixerNode.volume = Float(beatVolume)
        }
    }
    @Published var durationMinutes: Int = 25
    @Published var ambientMix: Double = MacFlowTonePreset.focus.defaultAmbientMix
    @Published var pulseDepth: Double = MacFlowTonePreset.focus.defaultPulseDepth
    @Published var selectedSource: AudioSource = .system {
        didSet {
            guard isPlaying else { return }
            switch selectedSource {
            case .system:
                startSystemCaptureIfPossible()
            case .file:
                stopSystemCapture()
            }
        }
    }
    @Published var systemAudioPermissionStatus = "Nicht angefragt"
    @Published private(set) var canCaptureSystemAudio: Bool = {
        if #available(macOS 13.0, *) {
            return true
        }
        return false
    }()

    private let engine = AVAudioEngine()
    private let beatMixerNode = AVAudioMixerNode()
    private let capturedAudioNode = AVAudioPlayerNode()
    private var beatSourceNode: AVAudioSourceNode?
    private var carrierPhase: Double = 0
    private var beatPhase: Double = 0
    private lazy var systemAudioManager = SystemAudioManager { [weak self] sampleBuffer in
        self?.enqueueCapturedSample(sampleBuffer)
    }
    private var startupRampTotalFrames: Int = 0
    private var startupRampFramesRemaining: Int = 0

    init() {
        configureEngine()
        refreshSystemAudioPermission()
    }

    var currentPreset: MacFlowTonePreset {
        MacFlowTonePreset(mode: currentMode)
    }

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startIfNeeded()
            if selectedSource == .system {
                startSystemCaptureIfPossible()
            } else {
                stopSystemCapture()
            }
        } else {
            stopSystemCapture()
            stopPlayback()
        }
    }

    func startSystemAudioCapture() {
        guard canCaptureSystemAudio else {
            systemAudioPermissionStatus = "Nicht verfugbar"
            return
        }

        let granted = CGPreflightScreenCaptureAccess() || CGRequestScreenCaptureAccess()
        systemAudioPermissionStatus = granted ? "Erlaubt" : "Verweigert"
        guard granted else {
            return
        }

        if isPlaying, selectedSource == .system {
            startSystemCaptureIfPossible()
        }
    }

    func refreshSystemAudioPermission() {
        guard canCaptureSystemAudio else {
            systemAudioPermissionStatus = "Nicht verfugbar"
            return
        }

        systemAudioPermissionStatus = CGPreflightScreenCaptureAccess() ? "Erlaubt" : "Nicht erlaubt"
    }

    var statusText: String {
        guard isPlaying else {
            return "Stopped"
        }

        return "Active • \(currentPreset.displayName) • \(durationMinutes) min"
    }

    var selectedFileLabel: String {
        switch selectedSource {
        case .system:
            return "System layer"
        case .file:
            return "File layer"
        }
    }

    func applyExample(_ example: MacFlowToneExample) {
        durationMinutes = example.durationMinutes
        currentMode = example.preset.mode
        applyPreset(example.preset, preserveDuration: true)
    }

    private func startIfNeeded() {
        guard !engine.isRunning else {
            return
        }

        let sampleRate = engine.outputNode.outputFormat(forBus: 0).sampleRate
        startupRampTotalFrames = max(1, Int(sampleRate * 0.05))
        startupRampFramesRemaining = startupRampTotalFrames

        do {
            try engine.start()
            if !capturedAudioNode.isPlaying {
                capturedAudioNode.play()
            }
        } catch {
            isPlaying = false
        }
    }

    private func stopPlayback() {
        guard engine.isRunning else {
            return
        }
        engine.pause()
    }

    private func configureEngine() {
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
        engine.attach(capturedAudioNode)
        engine.connect(sourceNode, to: beatMixerNode, format: format)
        engine.connect(capturedAudioNode, to: engine.mainMixerNode, format: format)
        engine.connect(beatMixerNode, to: engine.mainMixerNode, format: format)
        beatMixerNode.volume = Float(beatVolume)
    }

    private func renderBeatFrames(frameCount: Int, sampleRate: Double) -> [Float] {
        let preset = currentPreset
        let beatHz = preset.beatFrequencyHz
        let carrierHz = preset.carrierFrequencyHz
        let carrierIncrement = (2.0 * Double.pi * carrierHz) / sampleRate
        let beatIncrement = (2.0 * Double.pi * beatHz) / sampleRate

        var interleaved = Array(repeating: Float.zero, count: frameCount * 2)
        for frame in 0..<frameCount {
            let envelope: Double
            if startupRampFramesRemaining > 0, startupRampTotalFrames > 0 {
                let progressedFrames = startupRampTotalFrames - startupRampFramesRemaining
                envelope = min(1.0, Double(progressedFrames) / Double(startupRampTotalFrames))
                startupRampFramesRemaining -= 1
            } else {
                envelope = 1.0
            }
            let am = 0.5 + 0.5 * sin(beatPhase)
            let shapedAmplitude = 0.5 + (0.5 * am * pulseDepth)
            let sample = Float(sin(carrierPhase) * shapedAmplitude * envelope)

            interleaved[frame * 2] = sample
            interleaved[(frame * 2) + 1] = sample

            carrierPhase += carrierIncrement
            beatPhase += beatIncrement
            if carrierPhase > (2.0 * Double.pi) {
                carrierPhase -= 2.0 * Double.pi
            }
            if beatPhase > (2.0 * Double.pi) {
                beatPhase -= 2.0 * Double.pi
            }
        }
        return interleaved
    }

    private func startSystemCaptureIfPossible() {
        guard canCaptureSystemAudio else {
            systemAudioPermissionStatus = "Nicht verfugbar"
            return
        }

        do {
            try systemAudioManager.startSystemCapture()
            systemAudioPermissionStatus = "Erlaubt"
        } catch let error as SystemAudioCaptureError {
            switch error {
            case .permissionDenied:
                systemAudioPermissionStatus = "Verweigert"
            case .noDisplay:
                systemAudioPermissionStatus = "Kein Display gefunden"
            case .unavailable:
                systemAudioPermissionStatus = "Nicht verfugbar"
            }
        } catch {
            systemAudioPermissionStatus = "Fehler beim Start"
        }
    }

    private func stopSystemCapture() {
        systemAudioManager.stopSystemCapture()
    }

    private func enqueueCapturedSample(_ sampleBuffer: CMSampleBuffer) {
        guard selectedSource == .system, isPlaying else { return }
        guard let pcmBuffer = Self.pcmBuffer(from: sampleBuffer) else { return }

        if !capturedAudioNode.isPlaying {
            capturedAudioNode.play()
        }
        capturedAudioNode.scheduleBuffer(pcmBuffer, completionHandler: nil)
    }

    private static func pcmBuffer(from sampleBuffer: CMSampleBuffer) -> AVAudioPCMBuffer? {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer),
              let asbdPointer = CMAudioFormatDescriptionGetStreamBasicDescription(formatDescription) else {
            return nil
        }

        var asbd = asbdPointer.pointee
        guard let format = AVAudioFormat(streamDescription: &asbd) else {
            return nil
        }

        let frameCount = CMSampleBufferGetNumSamples(sampleBuffer)
        guard frameCount > 0,
              let pcmBuffer = AVAudioPCMBuffer(
                  pcmFormat: format,
                  frameCapacity: AVAudioFrameCount(frameCount)
              ) else {
            return nil
        }

        pcmBuffer.frameLength = AVAudioFrameCount(frameCount)

        let status = CMSampleBufferCopyPCMDataIntoAudioBufferList(
            sampleBuffer,
            at: 0,
            frameCount: Int32(frameCount),
            into: pcmBuffer.mutableAudioBufferList
        )
        guard status == noErr else {
            return nil
        }
        return pcmBuffer
    }

    private func applyPreset(_ preset: MacFlowTonePreset, preserveDuration: Bool) {
        ambientMix = preset.defaultAmbientMix
        pulseDepth = preset.defaultPulseDepth
        if !preserveDuration {
            durationMinutes = 25
        }
    }
}

final class MacAudioManager: AudioManager {}

enum SystemAudioCaptureError: Error {
    case permissionDenied
    case noDisplay
    case unavailable
}

final class SystemAudioManager: NSObject {
    private let captureQueue = DispatchQueue(label: "SystemAudioCaptureQueue")
    private let onBuffer: (CMSampleBuffer) -> Void
    private let streamOutput: SystemAudioStreamOutput
    private var stream: SCStream?

    init(onBuffer: @escaping (CMSampleBuffer) -> Void) {
        self.onBuffer = onBuffer
        self.streamOutput = SystemAudioStreamOutput(onBuffer: onBuffer)
        super.init()
    }

    func startSystemCapture() throws {
        guard #available(macOS 13.0, *) else {
            throw SystemAudioCaptureError.unavailable
        }

        if stream != nil {
            return
        }

        guard CGPreflightScreenCaptureAccess() else {
            throw SystemAudioCaptureError.permissionDenied
        }

        var startError: Error?
        var createdStream: SCStream?

        captureQueue.sync {
            let semaphore = DispatchSemaphore(value: 0)
            SCShareableContent.getExcludingDesktopWindows(false, onScreenWindowsOnly: true) { content, error in
                defer { semaphore.signal() }

                if let error {
                    startError = error
                    return
                }

                guard let display = content?.displays.first else {
                    startError = SystemAudioCaptureError.noDisplay
                    return
                }

                let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
                if #available(macOS 14.2, *) {
                    filter.includeMenuBar = false
                }

                let configuration = SCStreamConfiguration()
                configuration.capturesAudio = true
                configuration.width = max(display.width, 2)
                configuration.height = max(display.height, 2)
                configuration.minimumFrameInterval = CMTime(value: 1, timescale: 30)
                configuration.sampleRate = 48_000
                configuration.channelCount = 2

                let stream = SCStream(filter: filter, configuration: configuration, delegate: nil)

                do {
                    try self.addAudioOutput(to: stream)
                } catch {
                    startError = error
                    return
                }

                let startSemaphore = DispatchSemaphore(value: 0)
                stream.startCapture { error in
                    startError = error
                    startSemaphore.signal()
                }
                startSemaphore.wait()

                if startError == nil {
                    createdStream = stream
                }
            }
            semaphore.wait()
        }

        if let startError {
            throw startError
        }

        stream = createdStream
    }

    func stopSystemCapture() {
        guard let stream else { return }

        captureQueue.sync {
            let semaphore = DispatchSemaphore(value: 0)
            stream.stopCapture { _ in
                semaphore.signal()
            }
            semaphore.wait()
        }

        self.stream = nil
    }

    private func addAudioOutput(to stream: SCStream) throws {
        try stream.addStreamOutput(streamOutput, type: .audio, sampleHandlerQueue: captureQueue)
    }
}

final class SystemAudioStreamOutput: NSObject, SCStreamOutput {
    private let onBuffer: (CMSampleBuffer) -> Void

    init(onBuffer: @escaping (CMSampleBuffer) -> Void) {
        self.onBuffer = onBuffer
    }

    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard type == .audio else { return }
        onBuffer(sampleBuffer)
    }
}
