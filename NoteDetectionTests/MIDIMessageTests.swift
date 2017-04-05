//
//  MIDIMessageTests.swift

//
//  Created by flowing erik on 22.12.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

import XCTest
import NoteDetection

class MIDIMessageTests: XCTestCase {

    let arbitraryVelocity: Int = 100
    let arbitraryKey: Int = 69

    let noteOnStatus: UInt8 = 0b10010000
    let noteOffStatus: UInt8 = 0b10000000


    func testNoteOn() {
        let midiMessage = MIDIMessage(status: noteOnStatus, data1: UInt8(arbitraryKey), data2: UInt8(arbitraryVelocity))

        var isNoteOn: Bool?
        var messageKey: Int?
        var messageVelocity: Int?

        switch midiMessage! {
        case let .noteOn(key, velocity):
            isNoteOn = true
            messageKey = key
            messageVelocity = velocity
        default:
            break
        }

        XCTAssertTrue(isNoteOn!)
        XCTAssertEqual(messageVelocity!, arbitraryVelocity)
        XCTAssertEqual(messageKey!, arbitraryKey)
    }

    func testNoteOff() {
        let midiMessage = MIDIMessage(status: noteOffStatus, data1: UInt8(arbitraryKey), data2: UInt8(arbitraryVelocity))

        var isNoteOff: Bool?
        var messageKey: Int?
        var messageVelocity: Int?

        switch midiMessage! {
        case .noteOff(let (key, velocity)):
            isNoteOff = true
            messageKey = key
            messageVelocity = velocity
        default: break
        }

        XCTAssertTrue(isNoteOff!)
        XCTAssertEqual(messageVelocity!, arbitraryVelocity)
        XCTAssertEqual(messageKey!, arbitraryKey)
    }
}
