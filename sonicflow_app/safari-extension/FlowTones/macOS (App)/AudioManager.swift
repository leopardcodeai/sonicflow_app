import AVFoundation
import Combine
import CoreMedia
import CoreGraphics
import Foundation

enum AudioSource: String, CaseIterable {
    case system
    case file
}

class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentMode: FlowMode = .focus
    @Published var beatVolume: Double = 0.15 {
        didSet {
            beatMixerNode.volume = Float(beatVolume)
        }
    }
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
        if #available(macOS 14.2, *) {
            return true
        }
        return false
    }()

    private let beatEngine = BeatEngine()
    private let engine = AVAudioEngine()
    private let beatMixerNode = AVAudioMixerNode()
    private let capturedAudioNode = AVAudioPlayerNode()
    private var beatSourceNode: AVAudioSourceNode?
    private lazy var systemAudioManager = SystemAudioManager { [weak self] sampleBuffer in
        self?.enqueueCapturedSample(sampleBuffer)
    }

    init() {
        configureEngine()
        refreshSystemAudioPermission()
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
        }
    }

    func startSystemAudioCapture() {
        AVCaptureDevice.requestAccess(for: .audio) { [weak self] granted in
            DispatchQueue.main.async {
                guard let self else { return }

                if !granted {
                    self.systemAudioPermissionStatus = "Verweigert"
                    return
                }

                if !CGPreflightScreenCaptureAccess() {
                    _ = CGRequestScreenCaptureAccess()
                }

                self.systemAudioPermissionStatus = "Erlaubt"
                if self.isPlaying, self.selectedSource == .system {
                    self.startSystemCaptureIfPossible()
                }
            }
        }
    }

    func refreshSystemAudioPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized:
            systemAudioPermissionStatus = "Erlaubt"
        case .denied, .restricted:
            systemAudioPermissionStatus = "Verweigert"
        case .notDetermined:
            systemAudioPermissionStatus = "Nicht angefragt"
        @unknown default:
            systemAudioPermissionStatus = "Unbekannt"
        }
    }

    var statusText: String {
        guard isPlaying else {
            return "Stopped"
        }

        return "Active – \(currentMode.displayName) \(Int(currentMode.beatHz))Hz"
    }

    private func startIfNeeded() {
        guard !engine.isRunning else {
            return
        }

        do {
            try engine.start()
            if !capturedAudioNode.isPlaying {
                capturedAudioNode.play()
            }
        } catch {
            isPlaying = false
        }
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
        guard let buffer = try? beatEngine.generate(
            mode: currentMode,
            durationSeconds: Double(frameCount) / sampleRate,
            sampleRate: sampleRate
        ),
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

    private func startSystemCaptureIfPossible() {
        guard canCaptureSystemAudio else {
            systemAudioPermissionStatus = "Nicht verfügbar (< macOS 14.2)"
            return
        }

        do {
            try systemAudioManager.startSystemCapture()
            systemAudioPermissionStatus = "Erlaubt"
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
}

final class MacAudioManager: AudioManager {}

final class SystemAudioManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let outputQueue = DispatchQueue(label: "SystemAudioCaptureQueue")
    private let onBuffer: (CMSampleBuffer) -> Void
    private var output: AVCaptureAudioDataOutput?

    init(onBuffer: @escaping (CMSampleBuffer) -> Void) {
        self.onBuffer = onBuffer
        super.init()
    }

    func startSystemCapture() throws {
        guard !captureSession.isRunning else { return }
        guard let inputDevice = AVCaptureDevice.default(for: .audio) else {
            throw NSError(domain: "SystemAudioManager", code: 1, userInfo: nil)
        }

        captureSession.beginConfiguration()
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        captureSession.outputs.forEach { captureSession.removeOutput($0) }

        let input = try AVCaptureDeviceInput(device: inputDevice)
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let dataOutput = AVCaptureAudioDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: outputQueue)
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        output = dataOutput
        captureSession.commitConfiguration()

        captureSession.startRunning()
    }

    func stopSystemCapture() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
}

extension SystemAudioManager: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        onBuffer(sampleBuffer)
    }
}
