//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//
import Dispatch
import typealias Foundation.TimeInterval

#if os(Android)
import JNI
public typealias MIDITime = JavaLong
#else
import CoreMIDI
public typealias MIDITime = CoreMIDI.MIDITimeStamp
#endif


public final class MIDINoteDetector: NoteDetector {
    public weak var delegate: NoteDetectorDelegate?
    
    private(set) var currentMIDIKeys = Set<Int>()
    
    public init() {}

    public func process(midiMessage: MIDIMessage, from device: MIDIDevice?, at timestampMs: MIDITime) {
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
            
            guard let noteEvent = self.delegate?.expectedNoteEvent else {
                assertionFailure("an event was detected, but the delegates event is null.")
                return
            }

            DispatchQueue.main.async {
                self.delegate?.onNoteEventDetected(
                    noteDetector: self,
                    timestamp: TimeInterval(timestampMs),
                    detectedEvent: noteEvent
                )
            }
        }
    }

    private var currentVelocity: Float = 0 {
        didSet { delegate?.onInputLevelChanged(ratio: currentVelocity / 127) }
    }

    private var allExpectedNotesAreOn: Bool {
        guard let expectedKeys = self.delegate?.expectedNoteEvent?.notes else { return false }
        return currentMIDIKeys.isSuperset(of: expectedKeys) // allows not expected keys
    }
}
