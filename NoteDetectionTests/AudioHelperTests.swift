//
//  AudioHelperTests.swift
//  NativePitchDetection
//
//  Created by flowing erik on 13.01.16.
//  Copyright © 2016 Geordie Jay. All rights reserved.
//

import Foundation
import Accelerate
import XCTest
@testable import NoteDetection

class AudioHelperTests: XCTestCase {
    let midiNumberForA = MIDINumber(69)
    let frequencyForA: Float = 440

    func testDecibelToLinear() {
        let dbValue: Float = 0
        XCTAssertEqual(decibelToLinear(dbValue), 1)
    }

    func testLinearToDecibel() {
        var zeroReferenceValue: Float = 1
        let linearValues: [Float] = [0.01]
        let decibelValue = linearToDecibel(linearValues[0])
        var resultValues: [Float] = [0]

        vDSP_vdbcon(linearValues, 1, &zeroReferenceValue, &resultValues, 1, vDSP_Length(linearValues.count), 1)
        XCTAssertEqual(decibelValue, resultValues[0])
    }

    func testMidiToFrequency() {
        XCTAssertEqual(midiToFrequency(69+12), 880)
    }

    func testFrequencyToMidi() {
        XCTAssertEqual(frequencyToMidi(880), 69+12)
    }

    func testIsLocalExtreme() {
        let noExtreme: [Float] = [2, 3, 3, 3, 2]
        let withMaximum: [Float] = [4, 5, 6, 3, 0]
        let withMinimum: [Float] = [4, 1, 0, 4, 5]
        let checkPos = 2

        //should fail (not find a minimum)
        XCTAssertFalse(isLocalMaximum(amplitudes: noExtreme, centreIndex: checkPos))

        //should find a maximum
        XCTAssertTrue(isLocalMaximum(amplitudes: withMaximum, centreIndex: checkPos))

        //should find a minimum
        XCTAssertTrue(isLocalMinimum(amplitudes: withMinimum, centreIndex: checkPos))
    }
}
