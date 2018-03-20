//
//  MIDIMessage.swift

//
//  Created by flowing erik on 30.09.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

// Summary of MIDI Messages:
// https://www.midi.org/specifications/item/table-1-summary-of-midi-message

public enum MIDIMessage {
    case noteOn(key: UInt8, velocity: UInt8)
    case noteOff(key: UInt8)
    case systemExclusive(data: [UInt8])
//    case activeSensing // currently not handled
}

extension MIDIMessage: Equatable {
    public static func == (lhs: MIDIMessage, rhs: MIDIMessage) -> Bool {
        switch (lhs, rhs) {
        case let (.noteOn(leftNote, leftVelocity), .noteOn(rightNote, rightVelocity)):
            return (leftNote == rightNote) && (leftVelocity == rightVelocity)
        case let (.noteOff(leftNote), .noteOff(rightNote)):
            return (leftNote == rightNote)
//        case (.activeSensing, .activeSensing):
//            return true
        case let (.systemExclusive(dataA), .systemExclusive(dataB)):
            return dataA == dataB
        default:
            // All other cases are false.
            // We don't check the contents of sysex messages, so assume they're not equal either:
            return false
        }
    }
}
