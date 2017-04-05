//
//  Follower.swift
//  Follower
//
//  Created by Geordie Jay on 26.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//

protocol Follower: class {
    func didFollow()
    func shouldFollow() -> Bool
    var onNoteEventDetected: OnNoteEventDetectedCallback? { get set }
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
        onNoteEventDetected?(.now)
    }
}
