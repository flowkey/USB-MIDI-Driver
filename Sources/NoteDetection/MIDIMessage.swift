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
    case activeSensing
}

extension MIDIMessage: Equatable {
    public static func == (lhs: MIDIMessage, rhs: MIDIMessage) -> Bool {
        switch (lhs, rhs) {
        case let (.noteOn(leftNote, leftVelocity), .noteOn(rightNote, rightVelocity)):
            return (leftNote == rightNote) && (leftVelocity == rightVelocity)
        case let (.noteOff(leftNote), .noteOff(rightNote)):
            return (leftNote == rightNote)
        case (.activeSensing, .activeSensing):
            return true
        case let (.systemExclusive(dataA), .systemExclusive(dataB)):
            return dataA == dataB
        default:
            // All other cases are false.
            // We don't check the contents of sysex messages, so assume they're not equal either:
            return false
        }
    }
}


fileprivate enum MIDIMessageType: UInt8 {
    case noteOn
    case noteOff
    case systemExclusive
    case activeSensing
}

fileprivate extension UInt8 {
    var midiMessageType: MIDIMessageType? {
        if self == 0b1111_1110 { return .activeSensing }

        let command = self & 0b1111_0000 // bitmask status to get command
        switch command {
            case 0b1001_0000: return .noteOn
            case 0b1000_0000: return .noteOff
            case 0b1111_0000: return .systemExclusive
            default: break
        }

        return nil
    }
}

func parseMIDIMessages(from data: [UInt8]) -> [MIDIMessage] {
    var midiMessages: [MIDIMessage] = []
    var index: Int = 0
    while index < data.count {
        // check if value at current index corresponds to a midi command
        guard let messageType = data[index].midiMessageType else {
            index += 1
            continue
        }

        // determine end index for current message
        let endIndex: Int
        let message: MIDIMessage?
        switch messageType {
        case .activeSensing:
            endIndex = index
            message = MIDIMessage.activeSensing
        case .noteOn:
            endIndex = index + 2
            message = MIDIMessage.noteOn(key: data[index+1], velocity: data[index+2])
        case .noteOff:
            endIndex = index + 2
            message = MIDIMessage.noteOff(key: data[index+1])
        case .systemExclusive:
            let sysexEndIndex = data[index...].index(where: { $0 == 0b1111_0111 })
            endIndex = (sysexEndIndex ?? index)
            message = MIDIMessage.systemExclusive(data: Array<UInt8>(data[index ... endIndex]))
        }

        if let message = message {
            midiMessages.append(message)
        }

        // must be last step in the while loop
        index = endIndex + 1
    }

    return midiMessages
}

