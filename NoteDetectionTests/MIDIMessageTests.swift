//
//  MIDIMessageTests.swift
//  FlowCommons
//
//  Created by flowing erik on 22.12.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

import XCTest
import NoteDetection

class MIDIMessageTests: XCTestCase {

    let arbitraryVelocity: UInt8 = 100
    let arbitraryKey: UInt8 = 69

    let noteOnStatus: UInt8 = 0b10010000
    let noteOffStatus: UInt8 = 0b10000000


    func testNoteOn() {
        let midiMessage = MIDIMessage.from(status: noteOnStatus, data1: arbitraryKey, data2: arbitraryVelocity)

        var isNoteOn: Bool?
        var messageKey: UInt8?
        var messageVelocity: UInt8?

        switch midiMessage! {
        case .noteOn(let (key, velocity)):
            isNoteOn = true
            messageKey = key
            messageVelocity = velocity
        default: break
        }

        XCTAssertTrue(isNoteOn!)
        XCTAssertEqual(messageVelocity!, arbitraryVelocity)
        XCTAssertEqual(messageKey!, arbitraryKey)
    }

    func testNoteOff() {
        let midiMessage = MIDIMessage.from(status: noteOffStatus, data1: arbitraryKey, data2: arbitraryVelocity)

        var isNoteOff: Bool?
        var messageKey: UInt8?
        var messageVelocity: UInt8?

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
