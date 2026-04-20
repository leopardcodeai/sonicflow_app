import FlowTonesCore
import Foundation

struct FlowToneSettings: Equatable {
    var mode: FlowMode
    var durationMinutes: Int
    var ambientMix: Double
    var pulseDepth: Double

    static func standard(for mode: FlowMode, durationMinutes: Int = 25) -> Self {
        Self(
            mode: mode,
            durationMinutes: durationMinutes,
            ambientMix: ambientMix(for: mode),
            pulseDepth: pulseDepth(for: mode)
        )
    }

    private static func ambientMix(for mode: FlowMode) -> Double {
        switch mode {
        case .focus:
            return 0.45
        case .flow:
            return 0.55
        case .meditation:
            return 0.68
        case .sleep:
            return 0.78
        }
    }

    private static func pulseDepth(for mode: FlowMode) -> Double {
        switch mode {
        case .focus:
            return 0.95
        case .flow:
            return 0.78
        case .meditation:
            return 0.62
        case .sleep:
            return 0.46
        }
    }
}
