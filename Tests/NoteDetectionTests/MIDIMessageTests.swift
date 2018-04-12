//
//  MIDIMessageTests.swift

//
//  Created by flowing erik on 22.12.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection


let arbitraryNoteOnData: [UInt8] = [144 + 1, 50, 50] // channel=1, key=50, velocity=50
let arbitraryNoteOffData: [UInt8] = [128 + 1, 50, 50] // channel=1, key=50, velocity=50
let arbitrarySysexData: [UInt8] = [0b11110000, 50, 0b11110111] // sysexstart, arbitrary=50, syexend
let activeSensingData: [UInt8] = [254]

class MIDIParseTests: XCTestCase {
    func testSingleNoteOn() {
        let message: [MIDIMessage] = parseMIDIMessages(from: arbitraryNoteOnData)
        guard let firstMessage = message.first else {
            XCTFail("no message")
            return
        }
        XCTAssertEqual(firstMessage, MIDIMessage.noteOn(key: 50, velocity: 50))
    }

    func testSingleNoteOff() {
        let message: [MIDIMessage] = parseMIDIMessages(from: arbitraryNoteOffData)
        guard let firstMessage = message.first else {
            XCTFail("no message")
            return
        }
        XCTAssertEqual(firstMessage, MIDIMessage.noteOff(key: 50))
    }

    func testSingleNoteOffWhichHasNoteOnCommand() {
        let noteOnWithZeroVelocityData: [UInt8] = [144 + 1, 50, 0] // channel=1, key=50, velocity=0
        let message: [MIDIMessage] = parseMIDIMessages(from: noteOnWithZeroVelocityData)
        guard let firstMessage = message.first else {
            XCTFail("no message")
            return
        }
        XCTAssertEqual(firstMessage, MIDIMessage.noteOff(key: 50))
    }


    func testSingleSysex() {
        let message: [MIDIMessage] = parseMIDIMessages(from: arbitrarySysexData)
        guard let firstMessage = message.first else {
            XCTFail("no message")
            return
        }
        XCTAssertEqual(firstMessage, MIDIMessage.systemExclusive(data: arbitrarySysexData))
    }

    func testSingleActiveSensing() {
        let message: [MIDIMessage] = parseMIDIMessages(from: activeSensingData)
        guard let firstMessage = message.first else {
            XCTFail("no message")
            return
        }
        XCTAssertEqual(firstMessage, MIDIMessage.activeSensing)
    }

    func testMultipleMessages() {
        let multipleMessageData: [UInt8] =
            [arbitraryNoteOnData, arbitrarySysexData, activeSensingData, arbitraryNoteOffData].flatMap { $0 }

        let messages: [MIDIMessage] = parseMIDIMessages(from: Array<UInt8>(multipleMessageData))

        XCTAssertEqual(messages[0], MIDIMessage.noteOn(key: 50, velocity: 50))
        XCTAssertEqual(messages[1], MIDIMessage.systemExclusive(data: arbitrarySysexData))
        XCTAssertEqual(messages[2], MIDIMessage.activeSensing)
        XCTAssertEqual(messages[3], MIDIMessage.noteOff(key: 50))

    }
}

