//
//  NoteDetectionTests.swift
//  NoteDetection
//
//  Created by flowing erik on 12.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

var audioNoteDetectorDelegate: NoteDetectorTestDelegate? = nil

class NoteDetectionTests: XCTestCase {

    func testIfNoteDetectionIgnores() {
        let noteEventIsNotIgnored = XCTestExpectation(description: "note event is not ignored")
        noteEventIsNotIgnored.isInverted = true // the test passes if the expectation is never fulfilled

        let audioNoteDetector = AudioNoteDetector(sampleRate: 44100)
        audioNoteDetectorDelegate = NoteDetectorTestDelegate(callback: {
            noteEventIsNotIgnored.fulfill() // for the test to pass this should never be called
        })
        
        audioNoteDetector.delegate = audioNoteDetectorDelegate

        let arbitraryMidiNumber = MIDINumber(69)
        audioNoteDetector.pitchDetection.setExpectedEvent(NoteEvent(notes: [arbitraryMidiNumber]))

        let arbitaryIgnoreTime = 200.0
        audioNoteDetector.ignoreFor(ms: arbitaryIgnoreTime)

        let onsetTimestamp = Timestamp.now
        let noteTimestmap = onsetTimestamp + 50
        audioNoteDetector.onOnsetDetected(timestamp: onsetTimestamp)
        audioNoteDetector.onPitchDetected(timestamp: noteTimestmap)

        wait(for: [noteEventIsNotIgnored], timeout: 0.4)
    }
}
