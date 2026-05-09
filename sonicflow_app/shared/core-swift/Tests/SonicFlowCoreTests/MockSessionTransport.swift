import SonicFlowCore
import Foundation

public final class MockSessionTransport {
    public private(set) var startCallCount = 0
    public private(set) var pauseCallCount = 0
    public private(set) var lastMode: FlowMode?
    public private(set) var lastDurationMinutes: Int?
    public private(set) var capturedActions: [Action] = []

    public enum Action: Equatable {
        case start(mode: FlowMode, durationMinutes: Int)
        case pause
    }

    public struct OverrideClosures {
        public let start: () throws -> Void
        public let pause: () -> Void
    }

    public init() {}

    public func recordStart(mode: FlowMode, durationMinutes: Int) {
        startCallCount += 1
        lastMode = mode
        lastDurationMinutes = durationMinutes
        capturedActions.append(.start(mode: mode, durationMinutes: durationMinutes))
    }

    public func recordPause() {
        pauseCallCount += 1
        capturedActions.append(.pause)
    }

    public var startClosure: (() throws -> Void) {
        { [weak self] in
            self?.recordStart(mode: .focus, durationMinutes: 25)
        }
    }

    public var pauseClosure: () -> Void {
        { [weak self] in
            self?.recordPause()
        }
    }

    public func reset() {
        startCallCount = 0
        pauseCallCount = 0
        lastMode = nil
        lastDurationMinutes = nil
        capturedActions = []
    }
}
