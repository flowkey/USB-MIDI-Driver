//
//  NoteDetectionTests.swift
//  NoteDetection
//
//  Created by flowing erik on 12.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection


fileprivate let sampleRate = 44100.0

class NoteDetectionTests: XCTestCase {
    
    let arbitaryIgnoreTime = 200.0
    let arbitraryMidiNumber = MIDINumber(69)
    
    var audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)
    var audioNoteDetectorDelegate = NoteDetectorTestDelegate()
    
    override func setUp() {
        audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)
        audioNoteDetectorDelegate = NoteDetectorTestDelegate()
    }

    func testIfNoteDetectionIgnores() {
        let noteEventIsNotIgnored = XCTestExpectation(description: "note event is not ignored")
        noteEventIsNotIgnored.isInverted = true // the test passes if the expectation is never fulfilled

        audioNoteDetectorDelegate.callback = { noteEventIsNotIgnored.fulfill() } // for the test to callback should never be called
        audioNoteDetector.delegate = audioNoteDetectorDelegate
        
        audioNoteDetector.pitchDetection.setExpectedEvent(NoteEvent(notes: [arbitraryMidiNumber]))
        audioNoteDetector.ignoreFor(ms: arbitaryIgnoreTime)
        audioNoteDetector.onOnsetDetected(timestamp: 0.0)
        audioNoteDetector.onPitchDetected(timestamp: 50.0)

        wait(for: [noteEventIsNotIgnored], timeout: 0.4)
    }
    
}
