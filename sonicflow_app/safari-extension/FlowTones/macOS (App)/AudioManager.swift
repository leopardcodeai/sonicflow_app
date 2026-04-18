import AVFoundation
import Combine
import CoreGraphics
import Foundation

enum AudioSource: String, CaseIterable {
    case system
    case file
}

final class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentMode: FlowMode = .focus
    @Published var beatVolume: Double = 0.15 {
        didSet {
            beatMixerNode.volume = Float(beatVolume)
        }
    }
    @Published var selectedSource: AudioSource = .system
    @Published var systemAudioPermissionStatus = "Nicht angefragt"

    private let engine = AVAudioEngine()
    private let beatMixerNode = AVAudioMixerNode()
    private var beatSourceNode: AVAudioSourceNode?
    private var carrierPhase: Double = 0
    private var beatPhase: Double = 0

    init() {
        configureEngine()
        refreshSystemAudioPermission()
    }

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startIfNeeded()
        } else {
            stopPlayback()
        }
    }

    func startSystemAudioCapture() {
        if CGPreflightScreenCaptureAccess() {
            systemAudioPermissionStatus = "Erlaubt"
            return
        }

        let granted = CGRequestScreenCaptureAccess()
        systemAudioPermissionStatus = granted ? "Erlaubt" : "Verweigert"
    }

    func refreshSystemAudioPermission() {
        systemAudioPermissionStatus = CGPreflightScreenCaptureAccess() ? "Erlaubt" : "Nicht erlaubt"
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
        engine.connect(sourceNode, to: beatMixerNode, format: format)
        engine.connect(beatMixerNode, to: engine.mainMixerNode, format: format)
        beatMixerNode.volume = Float(beatVolume)
    }

    private func renderBeatFrames(frameCount: Int, sampleRate: Double) -> [Float] {
        let beatHz = currentMode.beatHz
        let carrierHz = currentMode.carrierHz
        let carrierIncrement = (2.0 * Double.pi * carrierHz) / sampleRate
        let beatIncrement = (2.0 * Double.pi * beatHz) / sampleRate
        let fade = min(0.05, Double(frameCount) / sampleRate / 2.0)

        var interleaved = Array(repeating: Float.zero, count: frameCount * 2)
        for frame in 0..<frameCount {
            let t = Double(frame) / sampleRate
            let envelope = min(1.0, t / max(fade, .leastNonzeroMagnitude))
            let am = 0.5 + 0.5 * sin(beatPhase)
            let sample = Float(sin(carrierPhase) * am * envelope)

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
}
