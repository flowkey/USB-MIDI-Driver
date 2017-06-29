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
