//
//  MemoryLeakTests.swift
//  NoteDetectionTests
//
//  Created by flowing erik on 04.04.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

private class MockAudioInput: AudioInput {
    var sampleRate: Double = 100
    var onSampleRateChanged: SampleRateChangedCallback?
    func start() throws {}
    func stop() throws {}
    func set(onAudioData: AudioDataCallback?) {
        print("onAudioData")
    }
}

class MemoryLeakTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPitchDetectionMemoryLeak() {
        let mockAudioInput = MockAudioInput()
        var audioNoteDetector: AudioNoteDetector? = AudioNoteDetector(input: mockAudioInput)
        weak var pitchDetection: PitchDetection? = audioNoteDetector?.pitchDetection

        audioNoteDetector = nil

        XCTAssertNil(pitchDetection)
    }
}
