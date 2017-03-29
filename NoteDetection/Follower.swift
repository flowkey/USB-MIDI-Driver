//
//  Follower.swift
//  Follower
//
//  Created by Geordie Jay on 26.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//

import FlowCommons


/// A Double signifying the time an event arrived, in milliseconds
public typealias Timestamp = Double

public protocol Follower: class {
    typealias EventListener = () -> Void

    init()
    func didFollow()
    func shouldFollow() -> Bool
    var onFollow: EventListener? { get set }
    var currentNoteEvent: NoteEvent? { get set }
}

extension Follower {
    func onInputReceived() {
        if shouldFollow() {
            follow()
            didFollow()
        }
    }

    func follow() {
        currentNoteEvent = nil
        onFollow?()
    }
}
