//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

let maxVelocity: Float = 127.0

final class MIDINoteDetector: NoteDetector {

    var onInputLevelChanged: OnInputLevelChangedCallback?
    var onNoteEventDetected: OnNoteEventDetectedCallback?
    var expectedNoteEvent: NoteEvent?
    var currentMIDIKeys = Set<Int>()

    public func process(midiMessage: MIDIMessage, from: MIDIDevice? = nil) {
        switch midiMessage {
        case .noteOn(let (key, velocity)):
            currentMIDIKeys.insert(Int(key))
            update(velocity)
        case .noteOff(let (key, velocity)):
            currentMIDIKeys.remove(Int(key))
            update(velocity)
        default: return
        }

        if allExpectedNotesAreOn() {
            onNoteEventDetected?(.now)
            currentMIDIKeys.removeAll()
            expectedNoteEvent = nil
        }
    }

    func update(_ velocity: UInt8) {
        let ratio = Float(velocity) / maxVelocity
        onInputLevelChanged?(ratio)
    }

    func allExpectedNotesAreOn() -> Bool {
        guard let expectedKeys = expectedNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }
}
