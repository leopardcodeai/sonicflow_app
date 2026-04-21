import XCTest
@testable import SonicFlow

final class FlowToneExampleTests: XCTestCase {
    func testStarterPackIncludesCuratedExamples() {
        let examples = FlowToneExample.starterPack

        XCTAssertEqual(examples.map(\.id), ["focus-primer", "flow-reset", "night-drift"])
        XCTAssertEqual(examples.map(\.settings.durationMinutes), [5, 5, 5])
        XCTAssertEqual(examples.last?.settings.preset, FlowTonePreset.sleep)
    }
}
