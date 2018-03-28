//
//  MIDIEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

class MIDIEngine: MIDIInput, MIDIOutput {
    private(set) var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    private(set) var onMIDIMessageReceived: MIDIMessageReceivedCallback?
    private(set) var onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?

    var onSysexMessageReceived: ((_ data: [UInt8], MIDIDevice) -> Void)?

    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var outputPort = MIDIPortRef()

    private(set) var midiDeviceList: Set<MIDIDevice> = []
    private(set) var midiOutConnections: [MIDIOutConnection] = []

    public init() throws {
        let clientName = "flowkey" as CFString
        let inputName = "flowkey input port" as CFString
        let outputName = "flowkey output port" as CFString

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

        try MIDIOutputPortCreate(midiClient, outputName, &outputPort)
            .throwOnError()

        connect()
    }

    deinit {
        print("deiniting MIDIEngine")
        MIDIPortDispose(inputPort)
        MIDIPortDispose(outputPort)
        MIDIClientDispose(midiClient)
    }

    func set(onMIDIMessageReceived callback: MIDIMessageReceivedCallback?) {
        self.onMIDIMessageReceived = { message, device, timestamp in
            DispatchQueue.main.async { callback?(message, device, timestamp) }
        }
    }

    func set(onMIDIDeviceListChanged callback: MIDIDeviceListChangedCallback?) {
        self.onMIDIDeviceListChanged = { devices in
            DispatchQueue.main.async { callback?(devices) }
        }
    }

    func set(onMIDIOutConnectionsChanged callback: MIDIOutConnectionsChangedCallback?) {
        // DispatchQueue.main.async ???
        self.onMIDIOutConnectionsChanged = callback
    }

    private func connect() {
        disconnect()

        // SOURCES
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

        self.onMIDIDeviceListChanged?(midiDeviceList)


        // DESTINATIONS
        for destIndex in 0 ..< MIDIGetNumberOfDestinations() {
            let destination = MIDIGetDestination(destIndex)
            if !destination.online || destination.isADisconnectedNetworkSession {
                continue // abort this iteration and start next
            }
            let destRefCon = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
            midiOutConnections.append(CoreMIDIOutConnection(
                source: outputPort,
                destination: destination,
                destRefCon: destRefCon)
            )
        }

        self.onMIDIOutConnectionsChanged?(midiOutConnections)
    }

    private func disconnect() {
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
        midiOutConnections = []
    }

    // MARK: MIDI Notification (Device added / removed)

    let onMIDIDeviceChangedProc: MIDINotifyProc = { (notificationPtr, refCon) in
        let `self` = unsafeBitCast(refCon, to: MIDIEngine.self)
        self.onMIDIDeviceChanged(notification: notificationPtr)
    }

    func onMIDIDeviceChanged(notification: UnsafePointer<MIDINotification>) {
        switch notification.pointee.messageID {
        case .msgObjectAdded: connect()
        case .msgObjectRemoved: connect()
        case .msgPropertyChanged: connect()
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
        let packets = makePacketsFromPacketList(packetList)
        let device = midiDeviceList.first { $0.refCon == srcConnRefCon }

        for packet in packets {
            let midiData = packet.toMIDIDataArray()
            let midiMessages = parseMIDIMessages(from: midiData)
            midiMessages.forEach { message in
                switch message {
                    case .activeSensing: break
                    case .systemExclusive(let data):
                        guard let device = device else { break }
                        onSysexMessageReceived?(data, device)
                    default:
                        onMIDIMessageReceived?(message, device, .now)
                }
            }
        }
    }
}


extension MIDIDevice {
    init(_ device: MIDIObjectRef, srcRefCon: UnsafeMutableRawPointer) {
        displayName = device.displayName
        uniqueID = device.uniqueID
        model = device.model
        manufacturer = device.manufacturer
        refCon = srcRefCon
    }
}
