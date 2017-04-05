//
//  FilterBankTests.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 10.03.17.
//  Copyright © 2017 Geordie Jay. All rights reserved.
//

import XCTest
@testable import NoteDetection

private protocol TestableFilterBank {
    var magnitudes: [Float] { get set }
    func calculateMagnitudes(_ inputBuffer: [Float])
}

extension FilterBank: TestableFilterBank {}
extension AppleFilterBank: TestableFilterBank {}

private let lowNote = MIDINumber(note: .c, octave: 1)
private let crossoverNote = MIDINumber(note: .c, octave: 4)
private let highNote = MIDINumber(note: .b, octave: 7)

class FilterBankTests: XCTestCase {
    let noteRange = lowNote ... highNote
    let largestMeanMagnitudeInSampleAudioFrame: Float = 7.47748e-05 // found by manually testing the sample data

    // Test any filterbank we have in the same way:
    private func runFilterbankTest<T: TestableFilterBank>(filterbank: T) -> Float {
        for _ in 0 ..< 500 {
            filterbank.calculateMagnitudes(sampleAudioFrame)
        }

        return max(filterbank.magnitudes)
    }

    func testAppleFilterbankPerformance() {
        measure {
            let filterbank = AppleFilterBank(noteRange: self.noteRange, sampleRate: 44100)
            let maxElement = self.runFilterbankTest(filterbank: filterbank)
            XCTAssertEqualWithAccuracy(maxElement, self.largestMeanMagnitudeInSampleAudioFrame, accuracy: 1e-06)
        }
    }

    func testFlowkeyFilterbankPerformance() {
        measure {
            let filterbank = FilterBank(
                lowRange: lowNote ... crossoverNote,
                highRange: crossoverNote + 1 ... highNote,
                sampleRate: 44100
            )

            let maxElement = self.runFilterbankTest(filterbank: filterbank)

            XCTAssertEqualWithAccuracy(maxElement, self.largestMeanMagnitudeInSampleAudioFrame, accuracy: 1e-06)
        }
    }
}
