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
