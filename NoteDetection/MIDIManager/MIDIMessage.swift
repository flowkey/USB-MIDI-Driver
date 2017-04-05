//
//  MIDIMessage.swift

//
//  Created by flowing erik on 30.09.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

// Summary of MIDI Messages:
// https://www.midi.org/specifications/item/table-1-summary-of-midi-message

fileprivate let commandBitmask: UInt8 = 0b11110000

public enum MIDIMessage {
    case noteOn(key: Int, velocity: Int)
    case noteOff(key: Int, velocity: Int)
    case controlChange(controller: Int, value: Int)
    case systemExclusive
    case activeSensing

    public init?(status: UInt8, data1: UInt8, data2: UInt8) {
        // check for midi messages with 8bit command type
        switch status {
        case UInt8.activeSensing: self = .activeSensing
        case UInt8.rawSysexStart: self = .systemExclusive
        default: break
        }

        // check for other messages with 4bit command type (mask out other 4 bits)
        let command = status & commandBitmask
        if (command == .rawNoteOff) || (command == .rawNoteOn && data2 == 0) {
            self = .noteOff(key: Int(data1), velocity: Int(data2))
        } else if command == .rawNoteOn {
            self = .noteOn(key: Int(data1), velocity: Int(data2))
        } else if command == .rawControlChange {
            self = .controlChange(controller: Int(data1), value: Int(data2))
        } else {
            return nil
        }
    }
}
