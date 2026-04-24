import FlowTonesCore
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

    /// Canonical hex identifier for the mode's chakra color.
    ///
    /// Kept as a public string for the existing test contract (see
    /// `FlowModePresentationTests`). All rendered color consumption routes
    /// through ``accentColor`` which resolves from `BrandTokens.Mode.*` —
    /// never parse this string for a real color at runtime.
    var accentColorHex: String {
        switch self {
        case .focus:
            return "#378ADD"
        case .flow:
            return "#7F77DD"
        case .meditation:
            return "#1D9E75"
        case .sleep:
            return "#534AB7"
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

    /// Chakra token backing this mode (see brand/BRAND.md mode↔chakra mapping).
    var chakraColor: Color {
        switch self {
        case .focus:
            return BrandTokens.Chakra.throat
        case .flow:
            return BrandTokens.Chakra.thirdEye
        case .meditation:
            return BrandTokens.Chakra.heart
        case .sleep:
            return BrandTokens.Chakra.crown
        }
    }
}
