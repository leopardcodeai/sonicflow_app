import CryptoKit
import SonicFlowCore
import Foundation

struct SonicFlowSettings: Codable, Equatable, Hashable, Sendable {
    static let durationRange = 5...60
    static let beatRange: ClosedRange<Double> = 1...48
    static let carrierRange: ClosedRange<Double> = 90...320
    static let ambientMixRange: ClosedRange<Double> = 0.2...1
    static let pulseDepthRange: ClosedRange<Double> = 0.2...1

    var preset: SonicFlowPreset
    var durationMinutes: Int
    var beatFrequencyHz: Double
    var carrierFrequencyHz: Double
    var ambientMix: Double
    var pulseDepth: Double

    var mode: FlowMode { preset.mode }

    static func standard(for preset: SonicFlowPreset, durationMinutes: Int = 25) -> Self {
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
        standard(for: SonicFlowPreset(mode: mode), durationMinutes: durationMinutes)
    }

    func applyingPreset(_ preset: SonicFlowPreset, preserveDuration: Bool = true) -> Self {
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

enum OfflineSessionAvailability: Equatable, Sendable {
    case notDownloaded
    case downloaded
    case storageFull

    var label: String {
        switch self {
        case .notDownloaded:
            return DesignLabels.text(.notDownloaded, language: .english)
        case .downloaded:
            return DesignLabels.text(.downloadedForOffline, language: .english)
        case .storageFull:
            return DesignLabels.text(.storageFull, language: .english)
        }
    }
}

struct OfflineSessionAsset: Equatable, Sendable {
    let id: String
    let settings: SonicFlowSettings
    let byteCount: Int

    init(settings: SonicFlowSettings, byteCount: Int) {
        self.id = settings.cacheKey
        self.settings = settings.clamped
        self.byteCount = max(0, byteCount)
    }
}

struct OfflineSessionLibrary: Equatable, Sendable {
    private(set) var assets: [String: OfflineSessionAsset] = [:]
    let storageLimitBytes: Int
    private var blockedAssetIds: Set<String> = []

    init(storageLimitBytes: Int) {
        self.storageLimitBytes = max(0, storageLimitBytes)
    }

    var usedBytes: Int {
        assets.values.reduce(0) { $0 + $1.byteCount }
    }

    mutating func store(_ asset: OfflineSessionAsset) -> Bool {
        let currentBytes = assets[asset.id]?.byteCount ?? 0
        let projectedBytes = usedBytes - currentBytes + asset.byteCount
        if projectedBytes > storageLimitBytes {
            blockedAssetIds.insert(asset.id)
            return false
        }

        blockedAssetIds.remove(asset.id)
        assets[asset.id] = asset
        return true
    }

    mutating func delete(settings: SonicFlowSettings) {
        let id = settings.cacheKey
        assets[id] = nil
        blockedAssetIds.remove(id)
    }

    func canStartOffline(settings: SonicFlowSettings) -> Bool {
        assets[settings.cacheKey] != nil
    }

    func availability(for settings: SonicFlowSettings) -> OfflineSessionAvailability {
        let id = settings.cacheKey
        if assets[id] != nil {
            return .downloaded
        }
        if blockedAssetIds.contains(id) {
            return .storageFull
        }
        return .notDownloaded
    }
}
