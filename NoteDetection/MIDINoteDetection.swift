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
    var expectedNoteEvent: DetectableNoteEvent?
    var currentMIDIKeys = Set<Int>()

    init(engine: MIDIEngine) {
        engine.onMIDIMessageReceived = process
    }

    public func process(midiMessage: MIDIMessage, from device: MIDIDevice? = nil) {
        switch midiMessage {
        case let .noteOn(key, velocity):
            currentMIDIKeys.insert(Int(key))
            currentVelocity = Float(velocity)
        case let .noteOff(key, velocity):
            currentMIDIKeys.remove(Int(key))
            currentVelocity = Float(velocity)
        default:
            return
        }

        if allExpectedNotesAreOn() {
            expectedNoteEvent = nil
            currentMIDIKeys.removeAll()

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
