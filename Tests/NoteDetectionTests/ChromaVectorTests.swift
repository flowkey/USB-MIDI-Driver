//
//  ChromaVectorTests.swift
//
//  Created by flowing erik on 30.09.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

import XCTest

@testable import NoteDetection

class ChromaTests: XCTestCase {
    func testComposeExpectedChroma() {
        // XXX: following variables depend on each other, just changing one value will break the test!
        let arbitraryLowKey = MIDINumber(note: .c, octave: 1) // 36
        let midiKeys: Set<MIDINumber> = [arbitraryLowKey, MIDINumber(note: .aSharp, octave: 3)]
        let valueToAddToFifthOfLowKey = ChromaVector.computeExpectedValueForFifth(of: arbitraryLowKey)

        // expected result for [36, 70]
        let expected = ChromaVector([0.5, 0, 0, 0, 0, 0, 0, valueToAddToFifthOfLowKey, 0, 0, 1, 0])
        let actual = ChromaVector(composeFrom: midiKeys)

        XCTAssertEqual(actual, expected!)
    }
}
