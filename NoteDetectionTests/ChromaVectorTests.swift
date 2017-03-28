//
//  FlowCommonsTests.swift
//  FlowCommonsTests
//
//  Created by flowing erik on 30.09.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

import XCTest
import FlowCommons
@testable import NoteDetection

class ChromaTests: XCTestCase {

    func testComposeExpectedChroma() {

        // XXX: following variables depend on each other, just changing one value will break the test!
        let arbitraryLowKey = 36
        let midiKeys: Set<MIDINumber> = [arbitraryLowKey, 70]
        let valueToAddToFifthOfLowKey = ChromaVector.computeExpectedValueForFith(of: arbitraryLowKey)

        // expected result for [36, 70]
        let expected: ChromaVector? = ChromaVector([0.5, 0, 0, 0, 0, 0, 0, valueToAddToFifthOfLowKey, 0, 0, 1, 0])

        let actual = ChromaVector.composeExpected(from: midiKeys)

        XCTAssertEqual(actual, expected!)
    }
}
