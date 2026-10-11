import AVFoundation
import AppKit
import Combine
import Foundation

enum MacSonicFlowLanguage: Equatable {
    case english
    case german

    static var system: MacSonicFlowLanguage {
        let preferred = Locale.preferredLanguages.first ?? Locale.current.identifier
        return preferred.lowercased().hasPrefix("de") ? .german : .english
    }

    func text(_ key: Key) -> String {
        switch (self, key) {
        case (.english, .notRequested): return "Not requested"
        case (.english, .unavailable): return "Unavailable"
        case (.english, .allowed): return "Allowed"
        case (.english, .denied): return "Denied"
        case (.english, .notAllowed): return "Not allowed"
        case (.english, .noDisplay): return "No display found"
        case (.english, .startError): return "Start failed"
        case (.english, .stopped): return "Stopped"
        case (.english, .active): return "Active"
        case (.german, .notRequested): return "Nicht angefragt"
        case (.german, .unavailable): return "Nicht verfugbar"
        case (.german, .allowed): return "Erlaubt"
        case (.german, .denied): return "Verweigert"
        case (.german, .notAllowed): return "Nicht erlaubt"
        case (.german, .noDisplay): return "Kein Display gefunden"
        case (.german, .startError): return "Fehler beim Start"
        case (.german, .stopped): return "Gestoppt"
        case (.german, .active): return "Aktiv"
        }
    }

    func modeName(_ mode: FlowMode) -> String {
        switch (self, mode) {
        case (.german, .focus): return "Fokus"
        case (.german, .flow): return "Flow"
        case (.german, .meditation): return "Meditation"
        case (.german, .sleep): return "Schlaf"
        default: return mode.displayName
        }
    }

    func modeDescription(_ mode: FlowMode) -> String {
        switch (self, mode) {
        case (.german, .focus): return "Gamma-Fokus-Boost"
        case (.german, .flow): return "Alpha-Konzentration"
        case (.german, .meditation): return "Theta-Ruhe-Tiefe"
        case (.german, .sleep): return "Delta-Tiefenruhe"
        default: return mode.shortDescription
        }
    }

    enum Key {
        case notRequested, unavailable, allowed, denied, notAllowed, noDisplay, startError
        case stopped, active
    }
}

enum MacPopoverDensity: String, CaseIterable, Identifiable, Codable {
    case compact
    case expanded

    var id: String { rawValue }
}

enum AudioMixBehavior: String, CaseIterable, Identifiable, Codable {
    case layer
    case duck
    case pause

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .layer: return "Layer"
        case .duck: return "Duck"
        case .pause: return "Pause"
        }
    }
}

struct AudioMixRule: Identifiable, Equatable, Codable {
    let id: String
    let appName: String
    let serviceName: String
    var behavior: AudioMixBehavior
    var beatVolume: Double
    var appVolume: Double

    static let defaults: [AudioMixRule] = [
        AudioMixRule(id: "spotify", appName: "Spotify", serviceName: "Spotify", behavior: .duck, beatVolume: 0.14, appVolume: 0.62),
        AudioMixRule(id: "youtube", appName: "Safari", serviceName: "YouTube", behavior: .layer, beatVolume: 0.12, appVolume: 0.76),
        AudioMixRule(id: "apple-music", appName: "Music", serviceName: "Apple Music", behavior: .duck, beatVolume: 0.12, appVolume: 0.68),
        AudioMixRule(id: "meetings", appName: "Meeting apps", serviceName: "Meetings", behavior: .pause, beatVolume: 0.0, appVolume: 1.0)
    ]
}

struct MacAudioContext: Equatable {
    let id: String
    let serviceName: String
    let appName: String

    static let unknown = MacAudioContext(id: "unknown", serviceName: "System", appName: "No media app detected")

    static func resolve(
        frontmostBundleIdentifier: String?,
        runningBundleIdentifiers: [String]
    ) -> MacAudioContext {
        let bundleIDs = ([frontmostBundleIdentifier].compactMap { $0 } + runningBundleIdentifiers)
            .map { $0.lowercased() }

        if bundleIDs.contains(where: { $0.contains("spotify") }) {
            return MacAudioContext(id: "spotify", serviceName: "Spotify", appName: "Spotify")
        }

        if bundleIDs.contains(where: { $0 == "com.apple.music" || $0.contains("music") }) {
            return MacAudioContext(id: "apple-music", serviceName: "Apple Music", appName: "Music")
        }

        if bundleIDs.contains(where: { $0.contains("zoom") || $0.contains("teams") || $0.contains("webex") || $0.contains("meet") }) {
            return MacAudioContext(id: "meetings", serviceName: "Meetings", appName: "Meeting apps")
        }

        if let frontmost = frontmostBundleIdentifier?.lowercased(),
           frontmost.contains("safari") {
            return MacAudioContext(id: "youtube", serviceName: "YouTube", appName: "Browser media")
        }

        return .unknown
    }
}

struct MacSonicFlowPreferences: Equatable, Codable {
    var popoverDensity: MacPopoverDensity = .expanded
    var showFloatingStatus: Bool = true
    var openAtLogin: Bool = false
    var respectMeetingAudio: Bool = true
}

enum MacSonicFlowPreset: String, CaseIterable, Identifiable, Codable {
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

struct MacSonicFlowExample: Identifiable, Equatable, Codable {
    let id: String
    let title: String
    let subtitle: String
    let preset: MacSonicFlowPreset
    let durationMinutes: Int

    static let starterPack: [MacSonicFlowExample] = [
        MacSonicFlowExample(
            id: "focus-primer",
            title: "Focus Primer",
            subtitle: "5 min gamma warmup",
            preset: .focus,
            durationMinutes: 5
        ),
        MacSonicFlowExample(
            id: "flow-reset",
            title: "Flow Reset",
            subtitle: "5 min alpha reset",
            preset: .flow,
            durationMinutes: 5
        ),
        MacSonicFlowExample(
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
            applyPreset(MacSonicFlowPreset(mode: currentMode), preserveDuration: true)
        }
    }
    @Published var beatVolume: Double = 0.15 {
        didSet {
            beatMixerNode.volume = Float(beatVolume)
        }
    }
    @Published var durationMinutes: Int = 25
    @Published var ambientMix: Double = MacSonicFlowPreset.focus.defaultAmbientMix
    @Published var pulseDepth: Double = MacSonicFlowPreset.focus.defaultPulseDepth
    @Published var recentExamples: [MacSonicFlowExample] = [] {
        didSet { persist(recentExamples, key: PersistenceKey.recents) }
    }
    @Published var favoriteExampleIDs: Set<String> = [] {
        didSet { persist(Array(favoriteExampleIDs), key: PersistenceKey.favorites) }
    }
    @Published var preferences = MacSonicFlowPreferences() {
        didSet { persist(preferences, key: PersistenceKey.preferences) }
    }
    @Published var audioMixRules = AudioMixRule.defaults {
        didSet { persist(audioMixRules, key: PersistenceKey.mixRules) }
    }
    @Published private(set) var activeAudioContext = MacAudioContext.unknown
    @Published private(set) var activeMixRuleID: String?

    private let engine = AVAudioEngine()
    private let beatMixerNode = AVAudioMixerNode()
    private var beatSourceNode: AVAudioSourceNode?
    private var carrierPhase: Double = 0
    private var beatPhase: Double = 0
    private var startupRampTotalFrames: Int = 0
    private var startupRampFramesRemaining: Int = 0

    init() {
        loadPersistedState()
        configureEngine()
        refreshActiveAudioContext()
    }

    var currentPreset: MacSonicFlowPreset {
        MacSonicFlowPreset(mode: currentMode)
    }

    func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startIfNeeded()
        } else {
            stopPlayback()
        }
    }

    var statusText: String {
        guard isPlaying else {
            return MacSonicFlowLanguage.system.text(.stopped)
        }

        return "\(MacSonicFlowLanguage.system.text(.active)) • \(MacSonicFlowLanguage.system.modeName(currentMode)) • \(durationMinutes) min"
    }

    func applyExample(_ example: MacSonicFlowExample) {
        durationMinutes = example.durationMinutes
        currentMode = example.preset.mode
        applyPreset(example.preset, preserveDuration: true)
        rememberRecent(example)
    }

    func toggleFavorite(_ example: MacSonicFlowExample) {
        if favoriteExampleIDs.contains(example.id) {
            favoriteExampleIDs.remove(example.id)
        } else {
            favoriteExampleIDs.insert(example.id)
        }
    }

    func isFavorite(_ example: MacSonicFlowExample) -> Bool {
        favoriteExampleIDs.contains(example.id)
    }

    func updateMixRule(_ rule: AudioMixRule, behavior: AudioMixBehavior) {
        audioMixRules = audioMixRules.map { current in
            guard current.id == rule.id else { return current }
            var updated = current
            updated.behavior = behavior
            return updated
        }
        applyFocusedMixRule()
    }

    func refreshActiveAudioContext(
        frontmostBundleIdentifier: String? = NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
        runningBundleIdentifiers: [String] = NSWorkspace.shared.runningApplications.compactMap(\.bundleIdentifier)
    ) {
        activeAudioContext = MacAudioContext.resolve(
            frontmostBundleIdentifier: frontmostBundleIdentifier,
            runningBundleIdentifiers: runningBundleIdentifiers
        )
        applyFocusedMixRule()
    }

    func applyFocusedMixRule() {
        let activeRule = audioMixRules.first { $0.id == activeAudioContext.id }
        activeMixRuleID = activeRule?.id

        guard let activeRule else {
            beatMixerNode.volume = Float(beatVolume)
            return
        }

        switch activeRule.behavior {
        case .layer:
            beatMixerNode.volume = Float(beatVolume)
        case .duck:
            beatMixerNode.volume = Float(min(beatVolume, activeRule.beatVolume))
        case .pause:
            if preferences.respectMeetingAudio, isPlaying {
                togglePlayback()
            }
        }
    }

    private func rememberRecent(_ example: MacSonicFlowExample) {
        recentExamples.removeAll { $0.id == example.id }
        recentExamples.insert(example, at: 0)
        if recentExamples.count > 5 {
            recentExamples = Array(recentExamples.prefix(5))
        }
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

    private func applyPreset(_ preset: MacSonicFlowPreset, preserveDuration: Bool) {
        ambientMix = preset.defaultAmbientMix
        pulseDepth = preset.defaultPulseDepth
        if !preserveDuration {
            durationMinutes = 25
        }
    }

    private enum PersistenceKey {
        static let recents = "sonicflow.mac.recents"
        static let favorites = "sonicflow.mac.favorites"
        static let preferences = "sonicflow.mac.preferences"
        static let mixRules = "sonicflow.mac.mixRules"
    }

    private func loadPersistedState(defaults: UserDefaults = .standard) {
        if let loadedRecents: [MacSonicFlowExample] = load(key: PersistenceKey.recents, defaults: defaults) {
            recentExamples = loadedRecents
        }

        if let loadedFavorites: [String] = load(key: PersistenceKey.favorites, defaults: defaults) {
            favoriteExampleIDs = Set(loadedFavorites)
        }

        if let loadedPreferences: MacSonicFlowPreferences = load(key: PersistenceKey.preferences, defaults: defaults) {
            preferences = loadedPreferences
        }

        if let loadedRules: [AudioMixRule] = load(key: PersistenceKey.mixRules, defaults: defaults), !loadedRules.isEmpty {
            audioMixRules = loadedRules
        }
    }

    private func persist<Value: Encodable>(_ value: Value, key: String, defaults: UserDefaults = .standard) {
        guard let data = try? JSONEncoder().encode(value) else {
            return
        }
        defaults.set(data, forKey: key)
    }

    private func load<Value: Decodable>(key: String, defaults: UserDefaults = .standard) -> Value? {
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(Value.self, from: data)
    }
}

final class MacAudioManager: AudioManager {}
