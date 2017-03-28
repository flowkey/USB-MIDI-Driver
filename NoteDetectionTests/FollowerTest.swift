//
//  FollowerTest.swift
//  Follower
//
//  Created by flowing erik on 29.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//

import XCTest
import FlowCommons
@testable import NoteDetection

final class DummyFollower: Follower {
    public var onFollow: Follower.EventListener?

    public var currentNoteEvent: NoteEvent?

    public func shouldFollow() -> Bool {
        return true
    }

    public func didFollow() {

    }
}

class FollowerTest: XCTestCase {

    var follower: DummyFollower?
    let marioEvents = anotherDayInParadiseNoteEvents

    override func setUp() {
        super.setUp()
        follower = DummyFollower()
    }

    override func tearDown() {
        follower = nil
        super.tearDown()
    }

}
