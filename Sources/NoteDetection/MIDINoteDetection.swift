//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public final class MIDINoteDetector: NoteDetector {
    public weak var inputLevelDelegate: InputLevelDelegate?
    public weak var noteEventDelegate: NoteEventDelegate?

    var currentMIDIKeys = Set<Int>()
    public var expectedNoteEvent: DetectableNoteEvent? {
        didSet { currentMIDIKeys.removeAll() }
    }
    
    public init() {}

    public func process(midiMessage: MIDIMessage) {
        switch midiMessage {
        case let .noteOn(key, velocity):
            currentMIDIKeys.insert(Int(key))
            currentVelocity = Float(velocity)
        case let .noteOff(key):
            currentMIDIKeys.remove(Int(key))
            if currentMIDIKeys.isEmpty {
                currentVelocity = Float(0)
            }
        default:
            return
        }

        if allExpectedNotesAreOn {
            // Clear the keys whenever user plays correctly, even if we were ignoring
            // Otherwise it would feel strange - you could hold the correct keys down
            // then press a random key and onNoteEventDetected would be triggered...
            currentMIDIKeys.removeAll()
            DispatchQueue.main.async {
                self.noteEventDelegate?.onNoteEventDetected(noteDetector: self, timestamp: .now)
            }
            expectedNoteEvent = nil
        }
    }

    private var currentVelocity: Float = 0 {
        didSet { inputLevelDelegate?.onInputLevelChanged(ratio: currentVelocity / 127) }
    }

    var allExpectedNotesAreOn: Bool {
        guard let expectedKeys = expectedNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }
}
