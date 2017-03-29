//
//  MidiFollower.swift
//  Follower
//
//  Created by flowing erik on 26.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//
import FlowCommons

public final class MIDIFollower: Follower {
    public init() {}
    public var currentNoteEvent: NoteEvent?
    public var onFollow: Follower.EventListener?

    internal var currentMIDIKeys = Set<Int>()

    public func onMIDIMessageReceived(_ midiMessage: MIDIMessage, from: MIDIDevice? = nil) {
        switch midiMessage {
        case .noteOn(let (key, _)) : currentMIDIKeys.insert(Int(key))
        case .noteOff(let (key, _)): currentMIDIKeys.remove(Int(key))
        default: return
        }

        onInputReceived()
    }

    public func shouldFollow() -> Bool {
        guard let expectedKeys = currentNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }

    public func didFollow() {
        currentMIDIKeys.removeAll()
    }
}
