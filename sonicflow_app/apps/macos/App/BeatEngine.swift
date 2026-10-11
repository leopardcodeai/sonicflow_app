import AVFoundation

public enum FlowMode: String, CaseIterable, Sendable {
    case focus
    case flow
    case meditation
    case sleep

    public var beatHz: Double {
        switch self {
        case .focus:
            return 40
        case .flow:
            return 10
        case .meditation:
            return 6
        case .sleep:
            return 2
        }
    }

    public var carrierHz: Double {
        switch self {
        case .focus, .flow:
            return 200
        case .meditation:
            return 180
        case .sleep:
            return 150
        }
    }
}

public struct BeatEngine: Sendable {
    public static let amplitude: Float = 0.12
    public static let fadeSeconds: Double = 5
    public static let defaultSampleRate: Double = 44_100

    public init() {}

    public func generate(
        mode: FlowMode,
        durationSeconds: Double,
        sampleRate: Double = defaultSampleRate
    ) throws -> AVAudioPCMBuffer {
        let frameCount = max(0, Int((durationSeconds * sampleRate).rounded(.down)))
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(frameCount))!
        buffer.frameLength = AVAudioFrameCount(frameCount)

        guard frameCount > 0 else {
            return buffer
        }

        guard let channelData = buffer.floatChannelData else {
            throw BeatEngineError.unavailableChannelData
        }

        let fadeFrames = min(Int((Self.fadeSeconds * sampleRate).rounded(.down)), frameCount / 2)

        for frame in 0..<frameCount {
            let time = Double(frame) / sampleRate
            let carrier = sin(2 * Double.pi * mode.carrierHz * time)
            let modulation = 0.5 + 0.5 * sin(2 * Double.pi * mode.beatHz * time)
            let envelope = envelope(at: frame, totalFrames: frameCount, fadeFrames: fadeFrames)
            let sample = Float(carrier * modulation) * Self.amplitude * envelope

            channelData[0][frame] = sample
            channelData[1][frame] = sample
        }

        return buffer
    }

    private func envelope(at index: Int, totalFrames: Int, fadeFrames: Int) -> Float {
        guard totalFrames > 1 else {
            return 0
        }

        guard fadeFrames > 0 else {
            return 1
        }

        if index < fadeFrames {
            return Float(index) / Float(fadeFrames)
        }

        let fadeOutStart = totalFrames - fadeFrames
        if index >= fadeOutStart {
            return max(Float(totalFrames - 1 - index) / Float(fadeFrames), 0)
        }

        return 1
    }
}

public enum BeatEngineError: Error, Sendable {
    case unavailableChannelData
}
