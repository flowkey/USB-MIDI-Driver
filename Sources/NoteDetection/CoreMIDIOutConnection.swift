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
    public var displayName: String {
        return destination.displayName
    }

    public static func == (lhs: CoreMIDIOutConnection, rhs: CoreMIDIOutConnection) -> Bool {
        return lhs.refCon == rhs.refCon
    }

    public func send(_ data: [UInt8]) {

        var packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
        let packetListSize = MemoryLayout<MIDIPacketList>.size + data.count
        var curPacket = MIDIPacketListInit(packetList)
        curPacket = MIDIPacketListAdd(packetList, packetListSize, curPacket, mach_absolute_time(), data.count, data)

        MIDISend(self.source, self.destination, packetList)

        curPacket.deinitialize()
        curPacket.deallocate(capacity: data.count)

        packetList.deinitialize()
        packetList.deallocate(capacity: 1)

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

