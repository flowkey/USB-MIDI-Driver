//
//  MIDIMessage+MIDIPacket.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import CoreMIDI

extension MIDIPacket {
    func toMIDIDataArray() -> [UInt8] {
        var data = self.data
        let count = Int(length)

        return withUnsafePointer(to: &data) { pointerToDataTuple in
            pointerToDataTuple.withMemoryRebound(to: UInt8.self, capacity: count) { pointerToFirstUInt8 in
                Array(UnsafeBufferPointer(start: pointerToFirstUInt8, count: count))
            }
        }
    }
}

