//
//  CoreMIDIOutConnection.swift
//  NoteDetection
//
//  Created by flowing erik on 22.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

public struct CoreMIDIOutConnection: MIDIOutConnection, Hashable {
    let source: MIDIPortRef
    let destination: MIDIEndpointRef
    let refCon: UnsafeMutablePointer<UInt32>
    public var hashValue: Int { return refCon.hashValue }

    init(source: MIDIPortRef, destination: MIDIEndpointRef, destRefCon: UnsafeMutablePointer<UInt32>) {
        self.source = source
        self.destination = destination
        self.refCon = destRefCon
    }

    // MARK: MIDIOutConnection Conformance
    public var displayName: String {
        return destination.displayName
    }

    public static func == (lhs: CoreMIDIOutConnection, rhs: CoreMIDIOutConnection) -> Bool {
        return lhs.refCon == rhs.refCon
    }

    public func send(messages: [[UInt8]]) {
        // Stay under the Clavinova's apparent 256 byte packetList size limit:
        let maxPacketListLength = 64

        // @Geordie: not really sure what we're doing in the following loop
        for i in stride(from: 0, to: messages.count, by: maxPacketListLength) {
            let events = messages.dropFirst(i).prefix(maxPacketListLength)
            var packetList = MIDIPacketList(from: Array(events))
            MIDISend(self.source, self.destination, &packetList)
        }
    }

    private let midiCompletionCallback: MIDICompletionProc = { request in
        print("completed sending sysex with request")
    }

    private var sysexSendRequestPointer = UnsafeMutablePointer<MIDISysexSendRequest>.allocate(capacity: 1)

    public func sendSysex(_ data: [UInt8]) {
        let sendRequest = MIDISysexSendRequest(
            destination: destination,
            data: data,
            bytesToSend: UInt32(data.count),
            complete: false,
            reserved: (0,0,0),
            completionProc: midiCompletionCallback,
            completionRefCon: nil
        )

        sysexSendRequestPointer.initialize(to: sendRequest)
        MIDISendSysex(sysexSendRequestPointer)
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
