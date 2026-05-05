import Foundation

#if canImport(ActivityKit)
import ActivityKit
#endif

#if canImport(ActivityKit)
@available(iOS 16.2, *)
struct SonicFlowLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let modeName: String
        let status: String
        let remainingMinutes: Int
        let isPlaying: Bool

        static func playback(isPlaying: Bool, modeName: String, durationMinutes: Int) -> ContentState {
            ContentState(
                modeName: modeName,
                status: isPlaying ? "Active" : "Paused",
                remainingMinutes: max(1, durationMinutes),
                isPlaying: isPlaying
            )
        }
    }

    let sessionName: String
}

final class SonicFlowLiveActivityBridge {
    func sync(isPlaying: Bool, modeName: String, durationMinutes: Int) {
        if #available(iOS 16.2, *) {
            Task { @MainActor in
                SonicFlowLiveActivityRuntime.shared.sync(
                    isPlaying: isPlaying,
                    modeName: modeName,
                    durationMinutes: durationMinutes
                )
            }
        }
    }
}

@available(iOS 16.2, *)
@MainActor
private final class SonicFlowLiveActivityRuntime {
    static let shared = SonicFlowLiveActivityRuntime()

    private var activity: Activity<SonicFlowLiveActivityAttributes>?

    func sync(isPlaying: Bool, modeName: String, durationMinutes: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            activity = nil
            return
        }

        let state = SonicFlowLiveActivityAttributes.ContentState.playback(
            isPlaying: isPlaying,
            modeName: modeName,
            durationMinutes: durationMinutes
        )
        let content = ActivityContent(
            state: state,
            staleDate: Calendar.current.date(byAdding: .minute, value: state.remainingMinutes, to: Date()),
            relevanceScore: isPlaying ? 0.9 : 0.2
        )

        Task {
            if isPlaying {
                if let activity {
                    await activity.update(content)
                } else {
                    let attributes = SonicFlowLiveActivityAttributes(sessionName: "SonicFlow")
                    activity = try? Activity.request(attributes: attributes, content: content, pushType: nil)
                }
            } else if let activity {
                await activity.end(content, dismissalPolicy: .immediate)
                self.activity = nil
            }
        }
    }
}
#else
final class SonicFlowLiveActivityBridge {
    func sync(isPlaying: Bool, modeName: String, durationMinutes: Int) {}
}
#endif
