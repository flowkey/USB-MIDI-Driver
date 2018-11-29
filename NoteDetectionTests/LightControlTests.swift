//
//  LightControlTests.swift
//  NoteDetectionTests
//
//  Created by Erik Werner on 21.11.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import XCTest
@testable import NoteDetection

class LightControlTests: XCTestCase {
    var yamahaLights = YamahaLights(midiEngine: nil)
    
    override func setUp() {
         yamahaLights = YamahaLights(midiEngine: nil)
    }

    func testIfStatusIsNotAvailableAfterInit() {
        XCTAssertEqual(yamahaLights.status, .notAvailable)
    }

    func testIfEnabledWhenControllerExists() {
        yamahaLights.controller = RegularLightController(connection: nil, midiEngine: nil)
        XCTAssertEqual(yamahaLights.status, .enabled)
    }

    func testDisabling() {
        yamahaLights.controller = RegularLightController(connection: nil, midiEngine: nil)
        yamahaLights.isEnabled = false
        XCTAssertEqual(yamahaLights.status, .disabled)
    }

    func testReEnabling() {
        yamahaLights.controller = RegularLightController(connection: nil, midiEngine: nil)
        yamahaLights.isEnabled = false
        yamahaLights.isEnabled = true
        XCTAssertEqual(yamahaLights.status, .enabled)
    }

    func testIfStatusChangesWhenControllerRemoved() {
        yamahaLights.controller = RegularLightController(connection: nil, midiEngine: nil)
        yamahaLights.controller = nil
        XCTAssertEqual(yamahaLights.status, .notAvailable)
    }

    func testIfStillNotAvailableAfterAttemptToEnableWithNoController() {
        XCTAssertNil(yamahaLights.controller)
        yamahaLights.isEnabled = true
        XCTAssertEqual(yamahaLights.status, LightControlStatus.notAvailable)
    }

    func testIfStillNotAvailableAfterAttemptToDisableWithNoController() {
        XCTAssertNil(yamahaLights.controller)
        yamahaLights.isEnabled = false
        XCTAssertEqual(yamahaLights.status, LightControlStatus.notAvailable)
    }

    func testLightsOffMessagePerOctave() {
        let lightsOffMessagesPerOctave = RegularLightController.createLightsOffMessagesPerOctave()
        let allMessages = lightsOffMessagesPerOctave.flatMap{ $0 }
        let keys = allMessages.map{ $0[1] };
        
        let expectedKeys = Array(UInt8(21)...UInt8(108))
        XCTAssertEqual(keys, expectedKeys)
    }

}
