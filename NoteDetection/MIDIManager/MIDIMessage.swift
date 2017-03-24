//
//  MIDIMessage.swift
//  FlowCommons
//
//  Created by flowing erik on 30.09.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

// Summary of MIDI Messages:
// https://www.midi.org/specifications/item/table-1-summary-of-midi-message

fileprivate let commandBitmask: UInt8 = 0b11110000

public enum MIDIMessage {
    case noteOn(key: UInt8, velocity: UInt8)
    case noteOff(key: UInt8, velocity: UInt8)
    case controlChange(controller: UInt8, value: UInt8)
    case systemExclusive
    case activeSensing

    public var statusByte: UInt8 { get {
        switch self {
        case .noteOn:           return UInt8.rawNoteOn
        case .noteOff:          return UInt8.rawNoteOff
        case .controlChange:    return UInt8.rawControlChange
        case .activeSensing:    return UInt8.activeSensing
        case .systemExclusive:  return UInt8.rawSysexStart
        }
    }}

    public static func from(status: UInt8, data1: UInt8, data2: UInt8) -> MIDIMessage? {
        // check for midi messages with 8bit command type
        switch status {
        case UInt8.activeSensing: return .activeSensing
        case UInt8.rawSysexStart: return .systemExclusive
        default: break
        }

        // check for other messages with 4bit command type (mask out other 4 bits)
        let command = status & commandBitmask
        if (command == .rawNoteOff) || (command == .rawNoteOn && data2 == 0) {
            return .noteOff(key: data1, velocity: data2)
        } else if command == .rawNoteOn {
            return .noteOn(key: data1, velocity: data2)
        } else if command == .rawControlChange {
            return .controlChange(controller: data1, value: data2)
        }

        return nil
    }
}
