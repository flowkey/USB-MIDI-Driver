//
//  FilterbankTests.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 10.03.17.
//  Copyright © 2017 Geordie Jay. All rights reserved.
//

import XCTest
@testable import NoteDetection

private protocol TestableFilterbank {
    var magnitudes: [Float] { get set }
    func calculateMagnitudes(_ inputBuffer: [Float]) -> [Float]
}

extension Filterbank: TestableFilterbank {}
extension AppleFilterbank: TestableFilterbank {}

private let lowNote = MIDINumber(note: .c, octave: 1)
private let crossoverNote = MIDINumber(note: .c, octave: 4)
private let highNote = MIDINumber(note: .b, octave: 7)

class FilterbankTests: XCTestCase {
    let noteRange = lowNote ... highNote

    /// Found by manually testing the sample data.
    /// Note this value you will be change depending on the Filters' Q value, so ensure you update both Filterbanks.
    let largestMeanMagnitudeInSampleAudioFrame: Float = 8.734285e-05

    // Test any filterbank we have in the same way:
    private func runFilterbankTest<T: TestableFilterbank>(filterbank: T) -> Float {
        var magnitudes = [Float]()

        for _ in 0 ..< 500 {
            magnitudes = filterbank.calculateMagnitudes(sampleAudioFrame)
        }

        return max(magnitudes)
    }

    func testAppleFilterbankPerformance() {
        measure {
            let filterbank = AppleFilterbank(noteRange: self.noteRange, sampleRate: 44100)
            let maxElement = self.runFilterbankTest(filterbank: filterbank)
            XCTAssertEqual(maxElement, self.largestMeanMagnitudeInSampleAudioFrame, accuracy: 1e-06)
        }
    }

    func testFlowkeyFilterbankPerformance() {
        let noteRange = NoteRange(fullRange: self.noteRange, lowNoteBoundary: crossoverNote)

        measure {
            let filterbank = Filterbank(
                noteRange: noteRange,
                sampleRate: 44100
            )

            let maxElement = self.runFilterbankTest(filterbank: filterbank)

            XCTAssertEqual(maxElement, self.largestMeanMagnitudeInSampleAudioFrame, accuracy: 1e-06)
        }
    }

    func testCalculateQFromBandwithInOctaves() {
        let bandWidthInOctaves: Double = 1 / 12
        let expectedQ: Double = 17.309941
        let q = calculateQFrom(bandWidthInOctaves: bandWidthInOctaves)

        XCTAssertEqual(expectedQ, q, accuracy: 0.00001)

        // a sanity check for the the change in the Filterbank.swift
        // can be removed for future changes of Filterbank.bandwidthInOctaves
        let previousQ = 120.0
        let currentQ = calculateQFrom(bandWidthInOctaves: Filterbank.bandwidthInOctaves)
        XCTAssertEqual(currentQ, previousQ, accuracy: 0.01)
    }

    func testFilterCoefficients() {
        let filter = Filter(sampleRate: 44100, centreFrequency: 440, Q: 100)
        // got groundtruth from https://arachnoid.com/BiQuadDesigner/ // gain=1
        let expected_a1: Float = -1.99544627
        let expected_a2: Float = 0.99937371
        let expected_b0: Float = 0.000313143531

        XCTAssertEqual(filter.a1, expected_a1)
        XCTAssertEqual(filter.a2, expected_a2)
        XCTAssertEqual(filter.b0, expected_b0)
    }

}
