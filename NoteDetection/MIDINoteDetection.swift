//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

final class MIDINoteDetector: NoteDetector {
    var onInputLevelChanged: InputLevelChangedCallback?
    var onNoteEventDetected: NoteEventDetectedCallback?

    var currentMIDIKeys = Set<Int>()
    var expectedNoteEvent: DetectableNoteEvent? {
        didSet { currentMIDIKeys.removeAll() }
    }

    init(input: MIDIInput) {
        input.set(onMIDIMessageReceived: process)
    }

    func process(midiMessage: MIDIMessage, from device: MIDIDevice? = nil) {
        switch midiMessage {
        case let .noteOn(key, velocity):
            currentMIDIKeys.insert(Int(key))
            currentVelocity = Float(velocity)
        case let .noteOff(key, _):
            currentMIDIKeys.remove(Int(key))
            if currentMIDIKeys.isEmpty {
                currentVelocity = Float(0)
            }
        default:
            return
        }

        if allExpectedNotesAreOn() {
            expectedNoteEvent = nil
            onNoteEventDetected?(.now)
        }
    }

    private var currentVelocity: Float = 0 {
        didSet { onInputLevelChanged?(currentVelocity / 127) }
    }

    private func allExpectedNotesAreOn() -> Bool {
        guard let expectedKeys = expectedNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }
}
