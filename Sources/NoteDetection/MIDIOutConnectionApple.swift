//
//  CoreMIDIOutConnection.swift
//  NoteDetection
//
//  Created by flowing erik on 22.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

public class MIDIOutConnection  {
    let source: MIDIPortRef
    let destination: MIDIEndpointRef
    let refCon: UnsafeMutablePointer<UInt32>

    init(source: MIDIPortRef, destination: MIDIEndpointRef, refCon: UnsafeMutablePointer<UInt32>) {
        self.source = source
        self.destination = destination
        self.refCon = refCon
    }

    public var displayName: String {
        return destination.displayName
    }

    public func send(messages: [[UInt8]]) {
        // Stay under the Clavinova's apparent 256 byte packetList size limit:
        let maxPacketListLength = 64

        // send multiple packet lists if messages exceed maxPacketListLength
        for i in stride(from: 0, to: messages.count, by: maxPacketListLength) {
            let messagesToSend = messages.dropFirst(i).prefix(maxPacketListLength)
            var packetList = MIDIPacketList(from: Array(messagesToSend))
            MIDISend(self.source, self.destination, &packetList)
        }
    }
}

extension MIDIOutConnection: Hashable {
    public var hashValue: Int { return refCon.hashValue }
    public static func == (lhs: MIDIOutConnection, rhs: MIDIOutConnection) -> Bool {
        return lhs.refCon == rhs.refCon
    }
}


private extension MIDIPacketList {
    init(from messageDataArr: [[UInt8]]) {
        let timestamp = mach_absolute_time()
        let totalBytesInAllEvents = messageDataArr.reduce(0) { total, event in
            return total + event.count
        }

        let listSize = MemoryLayout<MIDIPacketList>.size + totalBytesInAllEvents

        // CoreMIDI supports up to 65536 bytes, but the Clavinova doesn't seem to
        assert(totalBytesInAllEvents < 256, "The packet list was too long! Split your data into multiple lists.")

        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)

        messageDataArr.forEach { event in
            packet = MIDIPacketListAdd(&packetList, listSize, packet, timestamp, event.count, event)
        }

        self = packetList
    }
}
