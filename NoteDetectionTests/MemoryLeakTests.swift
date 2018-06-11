//
//  MemoryLeakTests.swift
//  NoteDetectionTests
//
//  Created by flowing erik on 04.04.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection


class MemoryLeakTests: XCTestCase {

    func testMIDINoteDetectorMemoryLeak() {
        var noteDetection: NoteDetection? = try! NoteDetection(input: .midi, audioSampleRate: 44100)
        weak var detector: MIDINoteDetector? = noteDetection?.noteDetector as? MIDINoteDetector

        XCTAssertNotNil(detector)
        noteDetection = nil
        XCTAssertNil(detector)
    }

    func testAudioNoteDetectorMemoryLeak() {
        var noteDetection: NoteDetection? = try! NoteDetection(input: .audio, audioSampleRate: 44100)
        weak var detector: AudioNoteDetector? = noteDetection?.noteDetector as? AudioNoteDetector

        XCTAssertNotNil(detector)
        noteDetection = nil
        XCTAssertNil(detector)
    }
    
    func testPitchDetectionMemoryLeak() {
        var audioNoteDetector: AudioNoteDetector? = AudioNoteDetector(sampleRate: 22050)
        weak var pitchDetection = audioNoteDetector?.pitchDetection

        XCTAssertNotNil(pitchDetection)
        audioNoteDetector = nil
        XCTAssertNil(pitchDetection)
    }

    func testOnsetDetectionMemoryLeak() {
        var audioNoteDetector: AudioNoteDetector? = AudioNoteDetector(sampleRate: 22050)
        weak var onsetDetection = audioNoteDetector?.onsetDetection

        XCTAssertNotNil(onsetDetection)
        audioNoteDetector = nil
        XCTAssertNil(onsetDetection)
    }

}
