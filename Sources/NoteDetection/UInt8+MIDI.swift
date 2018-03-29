//
//  UInt8+MIDI.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

extension UInt8 {
    static let highResVelocityPrefix: UInt8 = 88
    static let controlChange: UInt8         = 176
    static let activeSensing: UInt8         = 254

    static let rawNoteOn: UInt8 =          0b10010000
    static let rawNoteOff: UInt8 =         0b10000000
    static let rawControlChange: UInt8 =   0b00001011
    static let rawSysexStart: UInt8 =      0b11110000
}

extension Array where Element == UInt8 {
    func toMIDIMessages() -> [MIDIMessage] {
        var messages = [MIDIMessage]()

        for i in stride(from: 0, to: self.count, by: 3) {
            if self[i] == .activeSensing { continue }

            let lastIndexInSlice = (i + 2)
            if lastIndexInSlice >= self.count { continue } // ignore incomplete midi packets (avoid crashes)

            if let midiMessage = MIDIMessage(status: self[i + 0], data1: self[i + 1], data2: self[i + 2]) {
                messages.append(midiMessage)
            }
        }
        return messages
    }
}
