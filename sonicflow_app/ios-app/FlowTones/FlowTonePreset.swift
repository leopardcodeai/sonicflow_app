import FlowTonesCore
import Foundation

enum FlowTonePreset: String, CaseIterable, Codable, Identifiable, Sendable {
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

    var icon: String {
        switch self {
        case .focus: return "target"
        case .flow: return "bolt.fill"
        case .meditation: return "figure.mind.and.body"
        case .sleep: return "moon.stars.fill"
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

enum SessionProductMode: String, CaseIterable, Codable, Identifiable, Sendable {
    case focus
    case relax
    case sleep
    case meditate

    var id: String { rawValue }
}

enum SessionTimer: String, CaseIterable, Codable, Identifiable, Sendable {
    case pomodoro
    case short
    case standard
    case powerNap
    case infiniteSleep

    var id: String { rawValue }

    var durationMinutes: Int? {
        switch self {
        case .pomodoro:
            return 25
        case .short:
            return 5
        case .standard:
            return 25
        case .powerNap:
            return 20
        case .infiniteSleep:
            return nil
        }
    }
}

enum SessionActivity: String, CaseIterable, Codable, Identifiable, Sendable {
    case deepWork
    case creativeFlow
    case lightWork
    case learning
    case motivation
    case unwind
    case destress
    case recharge
    case chill
    case deepSleep
    case windDown
    case powerNap
    case guidedSleep
    case guidedMeditation
    case unguidedMeditation

    var id: String { rawValue }

    var productMode: SessionProductMode {
        switch self {
        case .deepWork, .creativeFlow, .lightWork, .learning, .motivation:
            return .focus
        case .unwind, .destress, .recharge, .chill:
            return .relax
        case .deepSleep, .windDown, .powerNap, .guidedSleep:
            return .sleep
        case .guidedMeditation, .unguidedMeditation:
            return .meditate
        }
    }

    var engineMode: FlowMode {
        switch self {
        case .deepWork, .learning, .motivation:
            return .focus
        case .creativeFlow, .lightWork, .unwind, .recharge, .chill:
            return .flow
        case .destress, .guidedMeditation, .unguidedMeditation:
            return .meditation
        case .deepSleep, .windDown, .powerNap, .guidedSleep:
            return .sleep
        }
    }

    var defaultTimer: SessionTimer {
        switch self {
        case .deepWork, .creativeFlow, .learning:
            return .pomodoro
        case .motivation, .recharge:
            return .short
        case .powerNap:
            return .powerNap
        case .deepSleep, .windDown, .guidedSleep:
            return .infiniteSleep
        case .lightWork, .unwind, .destress, .chill, .guidedMeditation, .unguidedMeditation:
            return .standard
        }
    }
}
