import SonicFlowCore
import SwiftUI

struct VisualizerView: View {
    let isPlaying: Bool
    let mode: FlowMode

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.15, paused: !isPlaying)) { context in
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<5, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(mode.accentColor)
                        .frame(width: 16, height: barHeight(index: index, date: context.date))
                        .animation(.spring(response: 0.35, dampingFraction: 0.72), value: context.date)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 84)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 14))
        }
    }

    private func barHeight(index: Int, date: Date) -> CGFloat {
        guard isPlaying else {
            return 14
        }

        let time = date.timeIntervalSinceReferenceDate
        let phase = time * (1.4 + Double(index) * 0.33) + Double(index) * 0.87
        let value = (sin(phase) + 1) / 2
        return 24 + CGFloat(value * 56)
    }
}
