import XCTest
@testable import SonicFlowCore

final class MockSessionTransportTests: XCTestCase {
    func testMockTransportRecordsStartAction() {
        let transport = MockSessionTransport()
        transport.recordStart(mode: .focus, durationMinutes: 25)

        XCTAssertEqual(transport.startCallCount, 1)
        XCTAssertEqual(transport.lastMode, .focus)
        XCTAssertEqual(transport.lastDurationMinutes, 25)
        XCTAssertEqual(transport.capturedActions, [.start(mode: .focus, durationMinutes: 25)])
    }

    func testMockTransportRecordsPauseAction() {
        let transport = MockSessionTransport()
        transport.recordPause()

        XCTAssertEqual(transport.pauseCallCount, 1)
        XCTAssertEqual(transport.capturedActions, [.pause])
    }

    func testMockTransportClosuresCanBeUsedAsOverrides() {
        let transport = MockSessionTransport()

        XCTAssertNoThrow(try transport.startClosure())
        XCTAssertEqual(transport.startCallCount, 1)

        transport.pauseClosure()
        XCTAssertEqual(transport.pauseCallCount, 1)
    }

    func testMockTransportResetClearsState() {
        let transport = MockSessionTransport()
        transport.recordStart(mode: .sleep, durationMinutes: 45)
        transport.recordPause()

        transport.reset()

        XCTAssertEqual(transport.startCallCount, 0)
        XCTAssertEqual(transport.pauseCallCount, 0)
        XCTAssertNil(transport.lastMode)
        XCTAssertNil(transport.lastDurationMinutes)
        XCTAssertTrue(transport.capturedActions.isEmpty)
    }

    func testMultipleActionsAreCapturedInOrder() {
        let transport = MockSessionTransport()
        transport.recordStart(mode: .focus, durationMinutes: 5)
        transport.recordStart(mode: .flow, durationMinutes: 10)
        transport.recordPause()

        XCTAssertEqual(transport.capturedActions, [
            .start(mode: .focus, durationMinutes: 5),
            .start(mode: .flow, durationMinutes: 10),
            .pause
        ])
    }
}
