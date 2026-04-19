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
