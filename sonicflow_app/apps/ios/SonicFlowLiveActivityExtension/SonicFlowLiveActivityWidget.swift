import ActivityKit
import SwiftUI
import WidgetKit

@main
struct SonicFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        SonicFlowLiveActivityWidget()
    }
}

struct SonicFlowLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SonicFlowLiveActivityAttributes.self) { context in
            SonicFlowLockScreenLiveActivityView(context: context)
                .activityBackgroundTint(Color(red: 0.12, green: 0.10, blue: 0.08))
                .activitySystemActionForegroundColor(Color(red: 0.90, green: 0.66, blue: 0.29))
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    SonicFlowIslandBadge(context: context)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("\(context.state.remainingMinutes)m")
                        .font(.title3.weight(.black))
                        .foregroundStyle(.white)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    SonicFlowIslandWaveform(isPlaying: context.state.isPlaying)
                }
            } compactLeading: {
                Image(systemName: context.state.isPlaying ? "waveform" : "pause.fill")
                    .foregroundStyle(Color(red: 0.90, green: 0.66, blue: 0.29))
            } compactTrailing: {
                Text("\(context.state.remainingMinutes)m")
                    .font(.caption2.weight(.black))
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: "waveform.circle.fill")
                    .foregroundStyle(Color(red: 0.90, green: 0.66, blue: 0.29))
            }
            .widgetURL(URL(string: "sonicflow://now-playing"))
            .keylineTint(Color(red: 0.90, green: 0.66, blue: 0.29))
        }
    }
}

private struct SonicFlowLockScreenLiveActivityView: View {
    let context: ActivityViewContext<SonicFlowLiveActivityAttributes>

    var body: some View {
        HStack(spacing: 14) {
            SonicFlowLeopardMark(isPlaying: context.state.isPlaying)

            VStack(alignment: .leading, spacing: 4) {
                Text(context.attributes.sessionName)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)

                Text(context.state.modeName)
                    .font(.headline.weight(.black))
                    .foregroundStyle(.primary)

                Text(context.state.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(context.state.isPlaying ? Color.green : Color.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(context.state.remainingMinutes)")
                    .font(.title.weight(.black))
                    .foregroundStyle(Color(red: 0.90, green: 0.66, blue: 0.29))
                Text("min")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
    }
}

private struct SonicFlowIslandBadge: View {
    let context: ActivityViewContext<SonicFlowLiveActivityAttributes>

    var body: some View {
        HStack(spacing: 8) {
            SonicFlowLeopardMark(isPlaying: context.state.isPlaying)
                .frame(width: 34, height: 34)

            VStack(alignment: .leading, spacing: 2) {
                Text("SonicFlow")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(context.state.modeName)
                    .font(.caption.weight(.black))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct SonicFlowIslandWaveform: View {
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<28, id: \.self) { index in
                Capsule()
                    .fill(Color(red: 0.90, green: 0.66, blue: 0.29))
                    .frame(width: 3, height: barHeight(index))
                    .opacity(isPlaying ? 0.95 : 0.36)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
    }

    private func barHeight(_ index: Int) -> CGFloat {
        let wave = abs(sin(Double(index) * 0.62))
        return CGFloat(6 + (wave * 22))
    }
}

private struct SonicFlowLeopardMark: View {
    let isPlaying: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.90, green: 0.66, blue: 0.29))

            Circle()
                .fill(.black.opacity(0.74))
                .frame(width: 7, height: 5)
                .offset(x: -7, y: -4)

            Circle()
                .fill(.black.opacity(0.74))
                .frame(width: 6, height: 4)
                .offset(x: 5, y: -6)

            Circle()
                .fill(.black.opacity(0.74))
                .frame(width: 8, height: 5)
                .offset(x: 2, y: 6)

            Image(systemName: isPlaying ? "waveform" : "play.fill")
                .font(.caption.weight(.black))
                .foregroundStyle(.black.opacity(0.78))
        }
        .frame(width: 42, height: 42)
    }
}
