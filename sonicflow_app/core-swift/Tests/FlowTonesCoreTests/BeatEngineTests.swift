import AVFoundation
import XCTest

@testable import FlowTonesCore

final class BeatEngineTests: XCTestCase {
    func testFlowModeConstantsMatchExpectedFrequencies() {
        XCTAssertEqual(FlowMode.allCases, [.focus, .flow, .meditation, .sleep])
        XCTAssertEqual(FlowMode.focus.beatHz, 40)
        XCTAssertEqual(FlowMode.focus.carrierHz, 200)
        XCTAssertEqual(FlowMode.flow.beatHz, 10)
        XCTAssertEqual(FlowMode.flow.carrierHz, 200)
        XCTAssertEqual(FlowMode.meditation.beatHz, 6)
        XCTAssertEqual(FlowMode.meditation.carrierHz, 180)
        XCTAssertEqual(FlowMode.sleep.beatHz, 2)
        XCTAssertEqual(FlowMode.sleep.carrierHz, 150)
    }

    func testGenerateProducesStereoPCMBufferWithExpectedFrameCount() throws {
        let engine = BeatEngine()
        let buffer = try engine.generate(mode: .focus, durationSeconds: 10, sampleRate: 1_000)

        XCTAssertEqual(buffer.format.channelCount, 2)
        XCTAssertEqual(buffer.frameLength, 10_000)
        XCTAssertEqual(buffer.format.commonFormat, .pcmFormatFloat32)
        XCTAssertNotNil(buffer.floatChannelData)
    }

    func testGenerateMirrorsLeftAndRightChannels() throws {
        let engine = BeatEngine()
        let buffer = try engine.generate(mode: .flow, durationSeconds: 6, sampleRate: 1_000)
        let left = buffer.floatChannelData![0]
        let right = buffer.floatChannelData![1]

        for index in 0..<50 {
            XCTAssertEqual(left[index], right[index], accuracy: 0.000001)
        }
    }

    func testGenerateAppliesFadeInAndFadeOut() throws {
        let engine = BeatEngine()
        let buffer = try engine.generate(mode: .meditation, durationSeconds: 12, sampleRate: 1_000)
        let left = buffer.floatChannelData![0]

        let startWindow = 0..<100
        let middleWindow = 5_500..<5_600
        let endWindow = 11_900..<12_000

        let startPeak = peakAmplitude(in: startWindow, channel: left)
        let middlePeak = peakAmplitude(in: middleWindow, channel: left)
        let endPeak = peakAmplitude(in: endWindow, channel: left)

        XCTAssertLessThan(startPeak, middlePeak)
        XCTAssertLessThan(endPeak, middlePeak)
    }

    private func peakAmplitude(in range: Range<Int>, channel: UnsafePointer<Float>) -> Float {
        range.reduce(0) { currentPeak, index in
            max(currentPeak, abs(channel[index]))
        }
    }
}
