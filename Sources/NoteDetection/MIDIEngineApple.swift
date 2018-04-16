//
//  MIDIEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

class MIDIEngine {
    private(set) var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    private(set) var onMIDIMessageReceived: MIDIMessageReceivedCallback?
    private(set) var onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?
    private(set) var onSysexMessageReceived: SysexMessageReceivedCallback?

    private var midiClient = MIDIClientRef()
    private var inputPort = MIDIPortRef()
    private var outputPort = MIDIPortRef()

    private(set) var midiDeviceList: Set<MIDIDevice> = []
    private(set) var midiOutConnections: Array<MIDIOutConnection> = []

    public init() throws {
        let clientName = "flowkey" as CFString
        let inputName = "flowkey input port" as CFString
        let outputName = "flowkey output port" as CFString

        #if os(iOS)
        MIDINetworkSession.default().isEnabled = true
        MIDINetworkSession.default().connectionPolicy = .anyone
        #endif

        let refCon = Unmanaged.passUnretained(self).toOpaque()
        try MIDIClientCreate(clientName, onMIDIDeviceChangedProc, refCon, &midiClient)
            .throwOnError()

        try MIDIInputPortCreate(midiClient, inputName, onMIDIPacketListReceivedProc, refCon, &inputPort)
            .throwOnError()

        try MIDIOutputPortCreate(midiClient, outputName, &outputPort)
            .throwOnError()

        connect()
    }

    deinit {
        MIDIPortDispose(inputPort)
        MIDIPortDispose(outputPort)
        MIDIClientDispose(midiClient)
    }

    func set(onMIDIMessageReceived callback: MIDIMessageReceivedCallback?) {
        self.onMIDIMessageReceived = callback
    }

    func set(onMIDIDeviceListChanged callback: MIDIDeviceListChangedCallback?) {
        self.onMIDIDeviceListChanged = callback
    }
    
    func set(onSysexMessageReceived callback: SysexMessageReceivedCallback?) {
        self.onSysexMessageReceived = callback
    }

    func set(onMIDIOutConnectionsChanged callback: MIDIOutConnectionsChangedCallback?) {
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

            do { try MIDIPortConnectSource(inputPort, source, srcRefCon).throwOnError() }
            catch {
                print("Failed to establish connection. Error: ", error.localizedDescription)
                continue
            }
            midiDeviceList.insert(MIDIDevice(source, srcRefCon: srcRefCon))
        }


        // DESTINATIONS
        for destIndex in 0 ..< MIDIGetNumberOfDestinations() {
            let destination = MIDIGetDestination(destIndex)
            let destRefCon = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
            midiOutConnections.append(CoreMIDIOutConnection(
                source: outputPort,
                destination: destination,
                refCon: destRefCon
            ))
        }
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

        switch notificationPtr.pointee.messageID {
        case .msgObjectAdded, .msgObjectRemoved, .msgPropertyChanged:
            self.connect() // refresh sources and destinations when something changed
            self.onMIDIOutConnectionsChanged?(self.midiOutConnections)
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
            let midiData = packet.toMIDIDataArray()
            let midiMessages = parseMIDIMessages(from: midiData)
            DispatchQueue.main.async {
                midiMessages.forEach { message in
                    switch message {
                    case .activeSensing: break
                    case .systemExclusive(let data):
                        guard let sourceDevice = sourceDevice else { break }
                        self.onSysexMessageReceived?(data, sourceDevice)
                    default:
                        self.onMIDIMessageReceived?(message, sourceDevice, .now)
                    }
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
