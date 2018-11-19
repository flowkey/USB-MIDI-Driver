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
}
