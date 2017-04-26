//
//  MIDIMessage+MIDIPacket.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import CoreMIDI

extension MIDIPacket {
    func toMIDIMessages() -> [MIDIMessage] {
        var messages = [MIDIMessage]()
        let data = packetDataToArray()

        for i in stride(from: 0, to: data.count, by: 3) {
            if data[i] == .activeSensing { continue }

            let lastIndexInSlice = (i + 2)
            if lastIndexInSlice >= data.count { continue } // ignore incomplete midi packets (avoid crashes)

            if let midiMessage = MIDIMessage(status: data[i + 0], data1: data[i + 1], data2: data[i + 2]) {
                messages.append(midiMessage)
            }
        }

        return messages
    }

    private func packetDataToArray() -> [UInt8] {
        var data = self.data
        let count = Int(length)

        return withUnsafePointer(to: &data) { pointerToDataTuple in
            pointerToDataTuple.withMemoryRebound(to: UInt8.self, capacity: count) { pointerToFirstUInt8 in
                Array(UnsafeBufferPointer(start: pointerToFirstUInt8, count: count))
            }
        }
    }
}
