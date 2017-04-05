//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

private let maxVelocity: Float = 127.0

final class MIDINoteDetector: NoteDetector {
    var onInputLevelChanged: OnInputLevelChangedCallback?
    var onNoteEventDetected: OnNoteEventDetectedCallback?
    var expectedNoteEvent: DetectableNoteEvent?
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

    private var currentVelocity: Float {
        didSet {} // update inputLevel to ratio
    }

    private func update(_ velocity: UInt8) {
        let ratio = Float(velocity) / maxVelocity
        onInputLevelChanged?(ratio)
    }

    private func allExpectedNotesAreOn() -> Bool {
        guard let expectedKeys = expectedNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }
}

