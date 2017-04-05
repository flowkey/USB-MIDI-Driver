//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//



final class MIDINoteDetector: NoteDetector {
    public var expectedNoteEvent: NoteEvent?

    public var onNoteEventDetected: OnNoteEventDetectedCallback?

    var currentMIDIKeys = Set<Int>()

    public func process(midiMessage: MIDIMessage, from: MIDIDevice? = nil) {
        switch midiMessage {
        case .noteOn(let (key, _)) : currentMIDIKeys.insert(Int(key))
        case .noteOff(let (key, _)): currentMIDIKeys.remove(Int(key))
        default: return
        }

        if allExpectedNotesAreOn() {
            onNoteEventDetected?(.now)
            currentMIDIKeys.removeAll()
            expectedNoteEvent = nil
        }
    }

    public func allExpectedNotesAreOn() -> Bool {
        guard let expectedKeys = expectedNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }
}
