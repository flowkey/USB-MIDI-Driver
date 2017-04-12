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

    var noteDetection = try! NoteDetection()

    override func setUp() {
        do { try noteDetection = NoteDetection() } catch { preconditionFailure() }
    }

    func testInputOverride() {
        let inititalInputType = noteDetection.inputType
        let newInputType = inititalInputType.toggle()

        // override to new input type
        noteDetection.overrideInputType(to: newInputType)

        XCTAssertNotEqual(inititalInputType, noteDetection.inputType)
    }

    func testInputChangeOnNewMIDIDevice() {
        noteDetection.overrideInputType(to: .audio)
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

        XCTAssertEqual(noteDetection.inputType, .midi)
    }

    func testIfCallbacksExistAfterSwitch() {
        let mockNoteEvent = NoteEvent(notes:[1], timeToNext: 1)

        // initially set callbacks
        noteDetection.set(onNoteEventDetected: { print($0) })
        noteDetection.set(onInputLevelChanged: { print($0) }) // FIXME: doesn't seem to have any effect
        noteDetection.noteDetector.onInputLevelChanged = { print($0) }
        noteDetection.set(expectedNoteEvent: mockNoteEvent)

        // precondition: all callbacks are initially set
        let allCallbacksInitiallyExist = noteDetection.noteDetector!.allCallbackExist()
        XCTAssertTrue(allCallbacksInitiallyExist)

        // switch input type
        noteDetection.overrideInputType(to: noteDetection.inputType.toggle())

        // check if callback still exist after switching input type
        let allCallbacksExistAfterSwitch = noteDetection.noteDetector!.allCallbackExist()
        XCTAssertTrue(allCallbacksExistAfterSwitch)
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
