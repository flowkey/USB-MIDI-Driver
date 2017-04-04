//
//  MIDIFollowerTest.swift
//  Follower
//
//  Created by flowing erik on 29.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//

import XCTest
@testable import NoteDetection

class MIDIFollowerTest: XCTestCase {

    var midiFollower: MIDIFollower = MIDIFollower()
    let noteEvents: [NoteEvent] = anotherDayInParadiseNoteEvents

    override func setUp() {
        super.setUp()
        midiFollower = MIDIFollower()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testIfFollowsOnRandomEvent() {

        let randomEventIndex = getRandomEventIndexFrom(noteEvents: noteEvents)

        midiFollower.currentNoteEvent = noteEvents[randomEventIndex]

        guard let noteEvent = midiFollower.currentNoteEvent else {
            XCTFail()
            return
        }

        for note in noteEvent.notes {
            let message = MIDIMessage.noteOn(key: UInt8(note), velocity: 10)
            midiFollower.onMIDIMessageReceived(message)
        }

        XCTAssertNil(midiFollower.currentNoteEvent)
    }

    func testIfMIDIArrayIsEmptyAfterOnFollow() {

        let eventIndex = 0

        midiFollower.currentNoteEvent = noteEvents[eventIndex]

        for note in midiFollower.currentNoteEvent!.notes {
            midiFollower.onMIDIMessageReceived(MIDIMessage.noteOn(key: UInt8(note), velocity: 10))
        }

        XCTAssertTrue(midiFollower.currentMIDIKeys.isEmpty)
    }

    func testIfMIDIArrayIsEmptyAfterNoteOff() {


        // add some keys
        midiFollower.onMIDIMessageReceived(MIDIMessage.noteOn(key: 69, velocity: 10))
        midiFollower.onMIDIMessageReceived(MIDIMessage.noteOn(key: 69+12, velocity: 10))


        // remove keys again
        midiFollower.onMIDIMessageReceived(MIDIMessage.noteOff(key: 69, velocity: 10))
        midiFollower.onMIDIMessageReceived(MIDIMessage.noteOff(key: 69+12, velocity: 10))


        XCTAssertTrue(midiFollower.currentMIDIKeys.isEmpty)

    }

    func testIfItFollowsWhenSetContainsNotExpectedKeys() {
        let randomEventIndex = getRandomEventIndexFrom(noteEvents: noteEvents)

        midiFollower.currentNoteEvent = noteEvents[randomEventIndex]

        // add not expected key
        midiFollower.onMIDIMessageReceived(MIDIMessage.noteOn(key: 0, velocity: 10))

        guard let noteEvent = midiFollower.currentNoteEvent else {
            XCTFail()
            return
        }

        // add expected keys
        for note in noteEvent.notes {
            midiFollower.onMIDIMessageReceived(MIDIMessage.noteOn(key: UInt8(note), velocity: 10))
        }

        XCTAssertNil(midiFollower.currentNoteEvent, "currentNoteEvent nil because it was detected previously")

    }

}


func getRandomEventIndexFrom(noteEvents: [NoteEvent]) -> Int {
    let randomEventIndex: Int = randomIntFromRange(lower: 0, upper: noteEvents.count - 1)
    return randomEventIndex
}


func randomIntFromRange (lower: Int, upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
