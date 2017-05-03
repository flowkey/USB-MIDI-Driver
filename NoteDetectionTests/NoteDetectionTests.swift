//
//  NoteDetectionTests.swift
//  NoteDetection
//
//  Created by flowing erik on 12.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

class NoteDetectionTests: XCTestCase {

    var noteDetection = try! NoteDetection(input: .audio)

    override func setUp() {
        do { try noteDetection = NoteDetection(input: .audio) } catch { preconditionFailure() }
    }

    func testInputOverride() {
        let inititalInputType = noteDetection.inputType
        let newInputType = inititalInputType.toggle()

        // override to new input type
        noteDetection.inputType = newInputType

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
        let mockNoteEvent = NoteEvent(notes:[1])

        // initially set callbacks
        noteDetection.set(onNoteEventDetected: { print($0) })
        noteDetection.set(onInputLevelChanged: { print($0) }) // FIXME: doesn't seem to have any effect
        noteDetection.noteDetector.onInputLevelChanged = { print($0) }
        noteDetection.set(expectedNoteEvent: mockNoteEvent)

        // precondition: all callbacks are initially set
        let allCallbacksInitiallyExist = noteDetection.noteDetector!.allCallbackExist()
        XCTAssertTrue(allCallbacksInitiallyExist)

        // switch input type
        noteDetection.inputType = noteDetection.inputType.toggle()

        // check if callback still exist after switching input type
        let allCallbacksExistAfterSwitch = noteDetection.noteDetector!.allCallbackExist()
        XCTAssertTrue(allCallbacksExistAfterSwitch)
    }

    func testIfNoteDetectionIgnores() {
        let expectation = self.expectation(description: "callback not exectued because noteDetection ignores")

        noteDetection.set(onNoteEventDetected: { _ in
            XCTFail("We shouldn't have detected a note because it should have been ignored")
        })

        let mockEvent = NoteEvent(notes: [1])
        noteDetection.set(expectedNoteEvent: mockEvent)

        noteDetection.inputType = .midi
        let midiNoteDetector = noteDetection.noteDetector as! MIDINoteDetector

        noteDetection.ignoreFor(durationInS: 0.1)

        afterTimeout(ms: 0.05, callback: {
            let message = MIDIMessage(status: .rawNoteOn, data1: 1, data2: 100)!
            midiNoteDetector.process(midiMessage: message)
        })

        afterTimeout(ms: 0.2, callback: {
            expectation.fulfill()
        })

        waitForExpectations(timeout: 0.3) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

}

extension NoteDetector {
    func allCallbackExist() -> Bool {
        return onInputLevelChanged != nil &&
               expectedNoteEvent   != nil &&
               onNoteEventDetected != nil
    }
}

extension InputType {
    func toggle() -> InputType {
        switch self {
            case .audio: return .midi
            case .midi: return .audio
        }
    }
}
