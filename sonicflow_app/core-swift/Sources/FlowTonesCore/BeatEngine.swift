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

public enum NeuralIntensity: String, CaseIterable, Sendable {
    case low
    case medium
    case high

    public var modulationDepth: Double {
        switch self {
        case .low:
            return 0.35
        case .medium:
            return 0.65
        case .high:
            return 0.95
        }
    }

    public var outputGain: Double {
        switch self {
        case .low:
            return 0.55
        case .medium:
            return 0.8
        case .high:
            return 1
        }
    }

    public var stereoPhaseOffset: Double {
        switch self {
        case .low:
            return 0
        case .medium:
            return Double.pi / 9
        case .high:
            return Double.pi / 4
        }
    }
}

public enum ModulationProgram: String, CaseIterable, Sendable {
    case focus
    case relax
    case sleep
    case meditate

    public var mode: FlowMode {
        switch self {
        case .focus:
            return .focus
        case .relax:
            return .flow
        case .sleep:
            return .sleep
        case .meditate:
            return .meditation
        }
    }
}

public struct ModulationProfile: Equatable, Sendable {
    public let program: ModulationProgram?
    public let mode: FlowMode
    public let intensity: NeuralIntensity
    public let targetBeatHz: Double
    public let carrierHz: Double
    public let modulationDepth: Double
    public let outputGain: Double
    public let stereoPhaseOffset: Double

    public static func program(_ program: ModulationProgram, intensity: NeuralIntensity) -> Self {
        let mode = program.mode
        return Self(
            program: program,
            mode: mode,
            intensity: intensity,
            targetBeatHz: mode.beatHz,
            carrierHz: mode.carrierHz,
            modulationDepth: intensity.modulationDepth,
            outputGain: intensity.outputGain,
            stereoPhaseOffset: intensity.stereoPhaseOffset
        )
    }

    static func legacy(mode: FlowMode) -> Self {
        Self(
            program: nil,
            mode: mode,
            intensity: .high,
            targetBeatHz: mode.beatHz,
            carrierHz: mode.carrierHz,
            modulationDepth: 1,
            outputGain: 1,
            stereoPhaseOffset: 0
        )
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
        try generate(
            profile: .legacy(mode: mode),
            durationSeconds: durationSeconds,
            sampleRate: sampleRate
        )
    }

    public func generate(
        profile: ModulationProfile,
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
            let carrier = sin(2 * Double.pi * profile.carrierHz * time)
            let leftModulation = amplitudeModulation(profile: profile, time: time, phaseOffset: 0)
            let rightModulation = amplitudeModulation(profile: profile, time: time, phaseOffset: profile.stereoPhaseOffset)
            let envelope = envelope(at: frame, totalFrames: frameCount, fadeFrames: fadeFrames)

            channelData[0][frame] = Float(carrier * leftModulation) * Self.amplitude * Float(profile.outputGain) * envelope
            channelData[1][frame] = Float(carrier * rightModulation) * Self.amplitude * Float(profile.outputGain) * envelope
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

    private func amplitudeModulation(profile: ModulationProfile, time: Double, phaseOffset: Double) -> Double {
        let lfo = 0.5 + 0.5 * sin((2 * Double.pi * profile.targetBeatHz * time) + phaseOffset)
        return (1 - profile.modulationDepth) + (profile.modulationDepth * lfo)
    }
}

public enum BeatEngineError: Error, Sendable {
    case unavailableChannelData
}
