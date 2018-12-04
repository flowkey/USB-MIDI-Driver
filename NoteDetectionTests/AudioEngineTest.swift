//
//  AudioEngineTest.swift
//  NoteDetectionTests
//
//  Created by Erik Werner on 04.12.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

class AudioEngineTest: XCTestCase {

    func testInputIsEnabled() {
        let audioEngine = try! AudioEngine()
        XCTAssertFalse(audioEngine.inputIsEnabled)
        
        try! audioEngine.startMicrophone()
        XCTAssertTrue(audioEngine.inputIsEnabled)
    }

    func testInputIsDisabled() {
        let audioEngine = try! AudioEngine()
        try! audioEngine.startMicrophone()
        try! audioEngine.stopMicrophone()
        
        XCTAssertFalse(audioEngine.inputIsEnabled)
    }
}
