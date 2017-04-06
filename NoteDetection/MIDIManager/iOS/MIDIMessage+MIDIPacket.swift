//
//  MIDIMessage+MIDIPacket.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import CoreMIDI

extension MIDIMessage {
    init?(from packet: MIDIPacket) {
        let data = packet.data
        let isHighResVelocityMessage = (data.0 == .controlChange) && (data.1 == .highResVelocityPrefix)
        let (command, key, velocity) =
            isHighResVelocityMessage ? (command: data.3, key: data.4, velocity: data.5) // ignores high res data
                                     : (command: data.0, key: data.1, velocity: data.2) // assume normal noteOn/Off

        if let message = MIDIMessage(status: command, data1: key, data2: velocity) {
            self = message
        } else {
            return nil
        }
    }
}
