//
//  MIDIEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

class MIDIEngine: MIDIInput {
    var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    var onMIDIMessageReceived: MIDIMessageReceivedCallback?

    var midiClient = MIDIClientRef()
    var inputPort = MIDIPortRef()

    public private(set) var midiDeviceList: Set<MIDIDevice> = []

    public init() throws {
        let clientName = "flowkey" as CFString
        let inputName = "flowkey input port" as CFString

        #if os(iOS)
        MIDINetworkSession.default().isEnabled = true
        MIDINetworkSession.default().connectionPolicy = .anyone
        #endif

        if #available(iOS 9.0, *) {
            try MIDIClientCreateWithBlock(clientName, &midiClient, onMIDIDeviceChanged)
                .throwOnError()
            try MIDIInputPortCreateWithBlock(midiClient, inputName, &inputPort, onMIDIPacketListReceived)
                .throwOnError()
        } else {
            let refCon = Unmanaged.passUnretained(self).toOpaque()
            try MIDIClientCreate(clientName, onMIDIDeviceChangedProc, refCon, &midiClient)
                .throwOnError()
            try MIDIInputPortCreate(midiClient, inputName, onMIDIPacketListReceivedProc, refCon, &inputPort)
                .throwOnError()
        }

        connect()
    }

    deinit {
        print("deiniting MIDIEngine")
        MIDIPortDispose(inputPort)
        MIDIClientDispose(midiClient)
    }

    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?) {
        self.onMIDIMessageReceived = onMIDIMessageReceived
    }

    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {
        self.onMIDIDeviceListChanged = onMIDIDeviceListChanged
    }

    func connect() {
        disconnect()

        for sourceIndex in 0 ..< MIDIGetNumberOfSources() {
            let source = MIDIGetSource(sourceIndex)


            if !source.online || source.isADisconnectedNetworkSession {
                continue // abort this iteration and start next
            }

            let srcRefCon = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
            do {
                try MIDIPortConnectSource(inputPort, source, srcRefCon).throwOnError()
            } catch {
                print("Failed to establish connection. Error: ", error.localizedDescription)
                continue
            }

            midiDeviceList.insert(MIDIDevice(source, srcRefCon: srcRefCon))
        }
    }

    func disconnect() {
        for sourceIndex in 0 ..< MIDIGetNumberOfSources() {
            let source = MIDIGetSource(sourceIndex)

            // according to core midi doc, connectionUniqueID is 0 if there is no connection
            guard source.connectionUniqueID != 0 else {
                print("\(source.displayName) has no connectionUniqueID (not connected)")
                continue
            }

            try? MIDIPortDisconnectSource(inputPort, source).throwOnError()
        }

        midiDeviceList = []
    }


    // MARK: MIDI Notification (Device added / removed)

    let onMIDIDeviceChangedProc: MIDINotifyProc = { (notificationPtr, refCon) in
        let `self` = unsafeBitCast(refCon, to: MIDIEngine.self)
        self.onMIDIDeviceChanged(notification: notificationPtr)
    }

    func onMIDIDeviceChanged(notification: UnsafePointer<MIDINotification>) {
        switch notification.pointee.messageID {
        case .msgObjectAdded, .msgObjectRemoved, .msgPropertyChanged:
            connect() // refresh sources when something changed
            DispatchQueue.main.async {
                self.onMIDIDeviceListChanged?(self.midiDeviceList)
            }
        default: break
        }
    }


    // MARK: Receive messages from a MIDI Device

    func makePacketsFromPacketList(_ packetList: UnsafePointer<MIDIPacketList>?) -> [MIDIPacket] {
        guard let packetList = packetList else { return [] }
        var packet = packetList.pointee.packet // this is index 0 of the packetList, so start with 1 in the loop below

        return [packet] + (1 ..< packetList.pointee.numPackets).map { _ in
            packet = MIDIPacketNext(&packet).pointee
            return packet
        }
    }

    let onMIDIPacketListReceivedProc: MIDIReadProc = { (packetList, readProcRefCon, srcConnRefCon) in
        let `self` = unsafeBitCast(readProcRefCon, to: MIDIEngine.self)
        self.onMIDIPacketListReceived(packetList: packetList, srcConnRefCon: srcConnRefCon)
    }

    func onMIDIPacketListReceived(packetList: UnsafePointer<MIDIPacketList>?, srcConnRefCon: UnsafeMutableRawPointer?) {
        let sourceDevice = midiDeviceList.first { $0.refCon == srcConnRefCon }
        let packets = makePacketsFromPacketList(packetList)

        for packet in packets {
            let midiMessages = packet.toMIDIDataArray().toMIDIMessages()

            DispatchQueue.main.async {
                midiMessages.forEach { midiMessage in
                    self.onMIDIMessageReceived?(midiMessage, sourceDevice, .now)
                }
            }
        }
    }
}


extension MIDIDevice {
    init(_ device: MIDIObjectRef, srcRefCon: UnsafeMutableRawPointer) {
        displayName = device.displayName
        uniqueID = device.uniqueID
        model = device.getStringProperty(kMIDIPropertyModel)
        manufacturer = device.getStringProperty(kMIDIPropertyManufacturer)
        refCon = srcRefCon
    }
}
