//
//  NoteDetectionTests.swift
//  NoteDetection
//
//  Created by flowing erik on 12.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

private let initialInputType = InputType.audio
private let alternativeInputType = InputType.midi

class NoteDetectionTests: XCTestCase {
    var noteDetection = try! NoteDetection(input: initialInputType, audioSampleRate: 44100)

    override func setUp() {
        noteDetection = try! NoteDetection(input: initialInputType, audioSampleRate: 44100)
    }

    func testInputOverride() {
        let inititalInputType = noteDetection.inputType
        XCTAssertNotEqual(inititalInputType, alternativeInputType)

        noteDetection.inputType = alternativeInputType
        XCTAssertNotEqual(inititalInputType, noteDetection.inputType)
    }

    func testIfCallbacksExistAfterSwitch() {
        // set callbacks
        noteDetection.set(onNoteEventDetected: { print($0) })
        noteDetection.set(onInputLevelChanged: { print($0) }) // FIXME: doesn't seem to have any effect
        noteDetection.noteDetector.onInputLevelChanged = { print($0) }
        noteDetection.set(expectedNoteEvent: NoteEvent(notes:[1]))

        // ensure all callbacks are set to begin with
        XCTAssert(noteDetection.noteDetector.allCallbacksExist())

        // switch input type
        noteDetection.inputType = alternativeInputType

        // ensure callbacks still exist
        XCTAssert(noteDetection.noteDetector.allCallbacksExist())
    }

    func testIfNoteDetectionIgnores() {
        let noteEventIsNotIgnored = XCTestExpectation(description: "note event is not ignored")
        noteEventIsNotIgnored.isInverted = true // the test passes if the expectation is never fulfilled

        noteDetection.inputType = .midi
        guard let midiNoteDetector = noteDetection.noteDetector as? MIDINoteDetector else {
            XCTFail("NoteDetector should have been set to MIDINoteDetector!")
            return
        }

        noteDetection.set(onNoteEventDetected: { _ in
            noteEventIsNotIgnored.fulfill() // for the test to pass this should never be called 
        })

        let arbitraryMidiNumber = MIDINumber(1)
        noteDetection.set(expectedNoteEvent: NoteEvent(notes: [arbitraryMidiNumber]))

        let arbitaryIgnoreTime = 200.0
        noteDetection.ignoreFor(ms: arbitaryIgnoreTime)

        let correctNoteOn = MIDIMessage.noteOn(key: UInt8(arbitraryMidiNumber), velocity: 100)
        midiNoteDetector.process(midiMessage: correctNoteOn)

        wait(for: [noteEventIsNotIgnored], timeout: 0.4)
    }
}

extension NoteDetector {
    func allCallbacksExist() -> Bool {
        return onInputLevelChanged != nil &&
               expectedNoteEvent   != nil &&
               onNoteEventDetected != nil
    }
}
