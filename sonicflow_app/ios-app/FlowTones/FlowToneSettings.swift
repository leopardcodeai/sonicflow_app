import CryptoKit
import FlowTonesCore
import Foundation

struct FlowToneSettings: Codable, Equatable, Hashable, Sendable {
    static let durationRange = 5...60
    static let beatRange: ClosedRange<Double> = 1...48
    static let carrierRange: ClosedRange<Double> = 90...320
    static let ambientMixRange: ClosedRange<Double> = 0.2...1
    static let pulseDepthRange: ClosedRange<Double> = 0.2...1

    var preset: FlowTonePreset
    var durationMinutes: Int
    var beatFrequencyHz: Double
    var carrierFrequencyHz: Double
    var ambientMix: Double
    var pulseDepth: Double

    var mode: FlowMode { preset.mode }

    static func standard(for preset: FlowTonePreset, durationMinutes: Int = 25) -> Self {
        Self(
            preset: preset,
            durationMinutes: durationMinutes,
            beatFrequencyHz: preset.beatFrequencyHz,
            carrierFrequencyHz: preset.carrierFrequencyHz,
            ambientMix: preset.defaultAmbientMix,
            pulseDepth: preset.defaultPulseDepth
        )
    }

    static func standard(for mode: FlowMode, durationMinutes: Int = 25) -> Self {
        standard(for: FlowTonePreset(mode: mode), durationMinutes: durationMinutes)
    }

    func applyingPreset(_ preset: FlowTonePreset, preserveDuration: Bool = true) -> Self {
        Self.standard(
            for: preset,
            durationMinutes: preserveDuration ? durationMinutes : 25
        )
    }

    var clamped: Self {
        Self(
            preset: preset,
            durationMinutes: min(Self.durationRange.upperBound, max(Self.durationRange.lowerBound, durationMinutes)),
            beatFrequencyHz: min(Self.beatRange.upperBound, max(Self.beatRange.lowerBound, beatFrequencyHz)),
            carrierFrequencyHz: min(Self.carrierRange.upperBound, max(Self.carrierRange.lowerBound, carrierFrequencyHz)),
            ambientMix: min(Self.ambientMixRange.upperBound, max(Self.ambientMixRange.lowerBound, ambientMix)),
            pulseDepth: min(Self.pulseDepthRange.upperBound, max(Self.pulseDepthRange.lowerBound, pulseDepth))
        )
    }

    var cacheKey: String {
        let normalized = clamped
        let canonical = [
            normalized.preset.rawValue,
            String(normalized.durationMinutes),
            String(format: "%.3f", normalized.beatFrequencyHz),
            String(format: "%.3f", normalized.carrierFrequencyHz),
            String(format: "%.3f", normalized.ambientMix),
            String(format: "%.3f", normalized.pulseDepth)
        ].joined(separator: "|")

        let digest = SHA256.hash(data: Data(canonical.utf8))
        return digest.prefix(6).map { String(format: "%02x", $0) }.joined()
    }
}
