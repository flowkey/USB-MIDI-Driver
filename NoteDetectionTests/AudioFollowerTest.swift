//
//  FollowerTests.swift
//  FollowerTests
//
//  Created by Geordie Jay on 26.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//

import XCTest
@testable import NoteDetection


func afterTimeout(ms timeout: Double, callback: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout / 1000, execute: callback)
}

class AudioFollowerTests: XCTestCase {

    var audioFollower: AudioFollower = AudioFollower()

    override func setUp() {
        super.setUp()
        audioFollower = AudioFollower()
    }

    override func tearDown() {
        super.tearDown()
    }


    func testTimestampsAreCloseEnough() {

        let expectation = self.expectation(description: "listener executed because timestamps are close enough")

        audioFollower.onFollow = { timestamp in
            expectation.fulfill()
        }

        afterTimeout(ms: 0, callback: { self.audioFollower.onOnsetDetected(timestamp: getTimeInMillisecondsSince1970()) })
        afterTimeout(ms: 100, callback: { self.audioFollower.onPitchDetected(timestamp: getTimeInMillisecondsSince1970()) })


        self.waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testTimestampsAreNotCloseEnough() {

        let expectation = self.expectation(description: "listener not executed because timestamps are NOT close enough")

        audioFollower.onFollow = { timestamp in
            XCTAssert(true)
        }


        afterTimeout(ms: 0, callback: { self.audioFollower.onOnsetDetected(timestamp: getTimeInMillisecondsSince1970()) })
        afterTimeout(ms: 300, callback: { self.audioFollower.onPitchDetected(timestamp: getTimeInMillisecondsSince1970()) })

        afterTimeout(ms: 500, callback: { expectation.fulfill() })

        self.waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
