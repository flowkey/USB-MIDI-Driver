//
//  MIDIMessageTests.swift

//
//  Created by flowing erik on 22.12.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

class MIDIMessageTests: XCTestCase {

    let arbitraryVelocity: Int = 100
    let arbitraryKey: Int = 69

    func testNoteOn() {
        XCTAssertEqual(
            MIDIMessage(status: .rawNoteOn, data1: UInt8(arbitraryKey), data2: UInt8(arbitraryVelocity)),
            MIDIMessage.noteOn(key: arbitraryKey, velocity: arbitraryVelocity)
        )
    }

    func testNoteOff() {
        XCTAssertEqual(
            MIDIMessage(status: .rawNoteOff, data1: UInt8(arbitraryKey), data2: UInt8(arbitraryVelocity)),
            MIDIMessage.noteOff(key: arbitraryKey)
        )
    }
}
