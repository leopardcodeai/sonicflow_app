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

public enum ResearchCondition: String, Sendable {
    case modulated
    case control
}

public enum SleepSpatializationLevel: String, Sendable {
    case off
    case low
    case medium
    case high

    var profile: SleepSpatializationProfile {
        switch self {
        case .off:
            return SleepSpatializationProfile(enabled: false, rockingHz: 0, panDepth: 0)
        case .low:
            return SleepSpatializationProfile(enabled: true, rockingHz: 0.04, panDepth: 0.12)
        case .medium:
            return SleepSpatializationProfile(enabled: true, rockingHz: 0.04, panDepth: 0.28)
        case .high:
            return SleepSpatializationProfile(enabled: true, rockingHz: 0.04, panDepth: 0.48)
        }
    }
}

public struct SleepSpatializationProfile: Equatable, Sendable {
    public let enabled: Bool
    public let rockingHz: Double
    public let panDepth: Double
}

public struct ModulationProfile: Equatable, Sendable {
    public let program: ModulationProgram?
    public let mode: FlowMode
    public let intensity: NeuralIntensity
    public let researchCondition: ResearchCondition
    public let targetBeatHz: Double
    public let carrierHz: Double
    public let modulationDepth: Double
    public let outputGain: Double
    public let stereoPhaseOffset: Double
    public let sleepSpatialization: SleepSpatializationProfile

    public static func program(
        _ program: ModulationProgram,
        intensity: NeuralIntensity,
        researchCondition: ResearchCondition = .modulated,
        sleepSpatialization: SleepSpatializationLevel = .off
    ) -> Self {
        let mode = program.mode
        let isControl = researchCondition == .control
        return Self(
            program: program,
            mode: mode,
            intensity: intensity,
            researchCondition: researchCondition,
            targetBeatHz: mode.beatHz,
            carrierHz: mode.carrierHz,
            modulationDepth: isControl ? 0 : intensity.modulationDepth,
            outputGain: intensity.outputGain,
            stereoPhaseOffset: isControl ? 0 : intensity.stereoPhaseOffset,
            sleepSpatialization: mode == .sleep ? sleepSpatialization.profile : SleepSpatializationLevel.off.profile
        )
    }

    static func legacy(mode: FlowMode) -> Self {
        Self(
            program: nil,
            mode: mode,
            intensity: .high,
            researchCondition: .modulated,
            targetBeatHz: mode.beatHz,
            carrierHz: mode.carrierHz,
            modulationDepth: 1,
            outputGain: 1,
            stereoPhaseOffset: 0,
            sleepSpatialization: SleepSpatializationLevel.off.profile
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
            let spatialGain = spatialGains(profile: profile, time: time)
            let envelope = envelope(at: frame, totalFrames: frameCount, fadeFrames: fadeFrames)

            channelData[0][frame] = Float(carrier * leftModulation) * Self.amplitude * Float(profile.outputGain) * envelope * spatialGain.left
            channelData[1][frame] = Float(carrier * rightModulation) * Self.amplitude * Float(profile.outputGain) * envelope * spatialGain.right
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

    private func spatialGains(profile: ModulationProfile, time: Double) -> (left: Float, right: Float) {
        let spatial = profile.sleepSpatialization
        guard spatial.enabled else {
            return (1, 1)
        }

        let pan = spatial.panDepth * sin(2 * Double.pi * spatial.rockingHz * time)
        let normalizer = 1 + spatial.panDepth
        return (
            Float((1 - pan) / normalizer),
            Float((1 + pan) / normalizer)
        )
    }
}

public enum BeatEngineError: Error, Sendable {
    case unavailableChannelData
}
