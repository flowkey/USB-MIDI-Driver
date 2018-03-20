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
    let destination: MIDIObjectRef
    let refCon: UnsafeMutablePointer<UInt32>
    public var hashValue: Int { return refCon.hashValue }

    init(source: MIDIPortRef, destination: MIDIObjectRef, destRefCon: UnsafeMutablePointer<UInt32>) {
        self.source = source
        self.destination = destination
        self.refCon = destRefCon
    }

    // MARK: MIDIOutConnection Conformance
    public var sourceID: Int {
        return source.uniqueID
    }
    public var destinationID: Int {
        return destination.uniqueID
    }

    public static func == (lhs: CoreMIDIOutConnection, rhs: CoreMIDIOutConnection) -> Bool {
        return lhs.refCon == rhs.refCon
    }

    public func send(_ singleMIDIMessageData: [UInt8]) {
        var packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        let packetListSize = MemoryLayout<MIDIPacketList>.size + singleMIDIMessageData.count
        var curPacket = MIDIPacketListInit(packetList)
        curPacket = MIDIPacketListAdd(packetList, packetListSize, curPacket, mach_absolute_time(), singleMIDIMessageData.count, singleMIDIMessageData)

        MIDISend(self.source, self.destination, packetList)

        curPacket.deinitialize()
        curPacket.deallocate(capacity: singleMIDIMessageData.count)

        packetList.deinitialize()
        packetList.deallocate(capacity: 1)
    }

    private let midiCompletionCallback: MIDICompletionProc = { request in
//        print("completed sending sysex with request: ", request.pointee)
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

