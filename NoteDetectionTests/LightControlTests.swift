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

    func testLightsOffMessagePerOctave() {
        let lightsOffMessagesPerOctave = RegularLightController.createLightsOffMessagesPerOctave()
        let allMessages = lightsOffMessagesPerOctave.flatMap{ $0 }
        let keys = allMessages.map{ $0[1] };
        
        let expectedKeys = Array(UInt8(21)...UInt8(108))
        XCTAssertEqual(keys, expectedKeys)
    }

}
