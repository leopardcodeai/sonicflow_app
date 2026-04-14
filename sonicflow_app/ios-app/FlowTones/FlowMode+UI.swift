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
        Color(hex: accentColorHex)
    }
}
