import SwiftUI

extension FlowMode {
    var displayName: String {
        switch self {
        case .focus:
            return "Focus"
        case .flow:
            return "Flow"
        case .meditation:
            return "Meditation"
        case .sleep:
            return "Sleep"
        }
    }

    var shortDescription: String {
        switch self {
        case .focus:
            return "Gamma focus boost"
        case .flow:
            return "Alpha concentration"
        case .meditation:
            return "Theta calm depth"
        case .sleep:
            return "Delta deep rest"
        }
    }

    var ritualTitle: String {
        switch self {
        case .focus:
            return "Focus Ritual"
        case .flow:
            return "Flow Ritual"
        case .meditation:
            return "Meditation Ritual"
        case .sleep:
            return "Sleep Ritual"
        }
    }

    var ritualSummary: String {
        switch self {
        case .focus:
            return "Gamma clarity for deep work and bright attention."
        case .flow:
            return "Alpha momentum for creative rhythm and smooth concentration."
        case .meditation:
            return "Theta spaciousness for breath, stillness, and recovery."
        case .sleep:
            return "Delta softness for slow unwinding and rest."
        }
    }

    var accentColor: Color {
        switch self {
        case .focus:
            return BrandTokens.Mode.focus
        case .flow:
            return BrandTokens.Mode.flow
        case .meditation:
            return BrandTokens.Mode.meditation
        case .sleep:
            return BrandTokens.Mode.sleep
        }
    }
}
