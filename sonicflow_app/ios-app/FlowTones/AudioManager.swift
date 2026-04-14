import AVFoundation
import FlowTonesCore
import Foundation

final class AudioManager: ObservableObject {
    @Published var isPlaying = false
    @Published var currentMode: FlowMode = .focus
    @Published var beatVolume: Double = 0.15 {
        didSet {
            beatMixerNode.volume = Float(beatVolume)
        }
    }

    private let beatEngine = BeatEngine()
    private let engine = AVAudioEngine()
    private let musicNode = AVAudioPlayerNode()
    private let beatMixerNode = AVAudioMixerNode()
    private var beatSourceNode: AVAudioSourceNode?

    init() {
        configureSession()
        configureEngine()
    }

    func togglePlayback() {
        isPlaying.toggle()
    }

    func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
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
