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
    var noteDetection = try! NoteDetection(input: initialInputType)

    override func setUp() {
        noteDetection = try! NoteDetection(input: initialInputType)
    }

    func testInputOverride() {
        let inititalInputType = noteDetection.inputType
        noteDetection.inputType = alternativeInputType

        XCTAssertNotEqual(inititalInputType, noteDetection.inputType)
    }

    // input should __NOT__ change automatically when midi device is connected
    func testInputDoesNotChangeOnNewMIDIDevice() {
        noteDetection.inputType = .audio
        XCTAssertEqual(noteDetection.inputType, .audio)
        noteDetection.set(onMIDIDeviceListChanged: nil)

        // add new MIDI device
        var arbitraryReferenceContext = 0
        noteDetection.midiEngine.onMIDIDeviceListChanged?([MIDIDevice(
            displayName: "TestDevice",
            manufacturer: "ACME",
            model: "midi_5000",
            uniqueID: 123456,
            refCon: &arbitraryReferenceContext
        )])

        XCTAssertNotEqual(noteDetection.inputType, .midi)
    }

    func testIfCallbacksExistAfterSwitch() {
        // set callbacks
        noteDetection.set(onNoteEventDetected: { print($0) })
        noteDetection.set(onInputLevelChanged: { print($0) }) // FIXME: doesn't seem to have any effect
        noteDetection.noteDetector.onInputLevelChanged = { print($0) }
        noteDetection.set(expectedNoteEvent: NoteEvent(notes:[1]))

        // ensure all callbacks are set to begin with
        XCTAssert(noteDetection.noteDetector!.allCallbacksExist())

        // switch input type
        noteDetection.inputType = alternativeInputType

        // ensure callbacks still exist
        XCTAssert(noteDetection.noteDetector!.allCallbacksExist())
    }

    func testIfNoteDetectionIgnores() {
        var noteWasDetected = false
        noteDetection.set(onNoteEventDetected: { _ in
            noteWasDetected = true
        })

        noteDetection.inputType = .midi
        guard let midiNoteDetector = noteDetection.noteDetector as? MIDINoteDetector else {
            XCTFail("NoteDetector should have been set to MIDINoteDetector!")
            return
        }

        let arbitraryMidiNumber = MIDINumber(1)
        noteDetection.set(expectedNoteEvent: NoteEvent(notes: [arbitraryMidiNumber]))

        let arbitaryIgnoreTime = 200.0
        noteDetection.ignoreFor(ms: arbitaryIgnoreTime)
        let correctNoteOn = MIDIMessage.noteOn(key: arbitraryMidiNumber, velocity: 100)
        let correctNoteOff = MIDIMessage.noteOff(key: arbitraryMidiNumber)

        midiNoteDetector.process(midiMessage: correctNoteOn, timestamp: .now)
        XCTAssert(noteWasDetected == false, "We shouldn't report notes detected within the ignore time")
        midiNoteDetector.process(midiMessage: correctNoteOff, timestamp: .now)

        midiNoteDetector.process(midiMessage: correctNoteOn, timestamp: .now + arbitaryIgnoreTime * 2)
        XCTAssert(noteWasDetected, "We should be able to detect again after the ignored time")
    }
}

extension NoteDetector {
    func allCallbacksExist() -> Bool {
        return onInputLevelChanged != nil &&
               expectedNoteEvent   != nil &&
               onNoteEventDetected != nil
    }
}
