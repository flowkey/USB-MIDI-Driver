//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import FlowCommons

public final class MIDINoteDetection: NoteDetectionProtocol {

    public let inputType: InputType = .midi

    let midiManager = try? MIDIManager()

    let follower = MIDIFollower()

    public var onEventDetected: (() -> Void)? {
        didSet { follower.onFollow = onEventDetected }
    }

    init() {
        midiManager?.onMIDIMessageReceived = follower.on
    }

    public func start() {
        midiManager?.connect()
    }

    public func stop() {
        midiManager?.disconnect()
    }

    public func setExpectedEvent(noteEvent: NoteEvent) {
        follower.currentNoteEvent = noteEvent
    }

}
