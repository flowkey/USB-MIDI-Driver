//
//  MIDIManager.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

// TODO: Clean up this mess of a MIDIManager, then remove swiftlint:disable
// swiftlint:disable file_length

import Foundation
import CoreMIDI

public class MIDIManager: MIDIManagerProtocol {

    public var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback?
    public var onMIDIMessageReceived: OnMIDIMessageReceivedCallback?

    var midiClient = MIDIClientRef()
    var clientInputPort = MIDIPortRef()

    public fileprivate(set) var midiDeviceList: Set<MIDIDevice> = []

    public init() throws {
        let clientName = "flowkey" as CFString
        let inputName = "flowkey input port" as CFString

        // Create the midi client and an input port for our client to receive midi messages
        if #available(iOS 9.0, *) {
            try MIDIClientCreateWithBlock(clientName, &midiClient, onMIDIDeviceChanged).throwOnError()
            try MIDIInputPortCreateWithBlock(midiClient, inputName, &clientInputPort, onMIDIPacketListReceived)
                .throwOnError()
        } else {
            let refCon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            try MIDIClientCreate(clientName, midiNotificationProc, refCon, &midiClient).throwOnError()
            try MIDIInputPortCreate(midiClient, inputName, onMIDIPacketListReceived, refCon, &clientInputPort)
                .throwOnError()
        }

        connect()
    }

    /// ios9 bug - keep ref to prevent bad_exec error on removal of the device
    /// details: http://stackoverflow.com/questions/32686214/removeconnection-results-in-exc-bad-access
    private var defaultNetworkSession: MIDINetworkSession = MIDINetworkSession.default()
    private var oldNetworkMIDIConnections: Set<MIDINetworkConnection> = []

    private func networkSessionIsConnected() -> Bool {
        let activeConnections = defaultNetworkSession.connections()
        if activeConnections.isEmpty { return false }

        oldNetworkMIDIConnections.formUnion(activeConnections)
        return true
    }

    public func connect() {
        disconnect()

        let noNetworkSessionConnected = !self.networkSessionIsConnected()
        for sourceIndex in 0 ..< MIDIGetNumberOfSources() {
            let source = MIDIGetSource(sourceIndex)

            if !source.online || source.isNetworkSession && noNetworkSessionConnected {
                continue // abort this iteration and start next
            }

            let srcRefCon = UnsafeMutablePointer<UInt32>.allocate(capacity: 0)
            do {
                try MIDIPortConnectSource(clientInputPort, source, srcRefCon).throwOnError()
            } catch {
                print("Failed to establish connection. Error: ", error.localizedDescription)
                continue
            }

            midiDeviceList.insert(MIDIDevice(source, srcRefCon: srcRefCon))
        }
    }

    public func disconnect() {
        for sourceIndex in 0 ..< MIDIGetNumberOfSources() {
            let source = MIDIGetSource(sourceIndex)

            // according to core midi doc, connectionUniqueID is 0 if there is no connection
            guard source.connectionUniqueID != 0 else {
                print("\(source.displayName) has no connectionUniqueID (not connected)")
                continue
            }

            do {
                try MIDIPortDisconnectSource(clientInputPort, source).throwOnError()
            } catch {
                print("Failed to disconnect. Error: \(error.localizedDescription)")
                continue
            }
        }

        midiDeviceList = []
    }


    /*
     * MARK: MIDI Notification (Device added / removed)
     */
    let midiNotificationProc: MIDINotifyProc = { (notificationPtr, refCon) in
        let midiManagerSelf = unsafeBitCast(refCon, to: MIDIManager.self)
        midiManagerSelf.onMIDIDeviceChanged(notification: notificationPtr)
    }

    func onMIDIDeviceChanged(notification: UnsafePointer<MIDINotification>) {
        let msgId = notification.pointee.messageID
        if msgId == .msgObjectAdded || msgId == .msgObjectRemoved || msgId == .msgPropertyChanged {
            connect()    // refresh sources when something changed

            DispatchQueue.main.async {
                self.onMIDIDeviceListChanged?(self.midiDeviceList)
            }
        }
    }


    /*
     * MARK: Receive messages from a MIDI Device
     */

    func findOnlineMIDIDeviceFromRefCon(_ refCon: UnsafeMutableRawPointer?) -> MIDIDevice? {
        for device in midiDeviceList {
            if device.refCon == refCon {
                return device
            }
        }
        return nil
    }

    func makePacketsFromPacketList(_ packetList: UnsafePointer<MIDIPacketList>?) -> [MIDIPacket] {
        guard let packetList = packetList else { return [] }
        var packet = packetList.pointee.packet // this is index 0 of the packetList, so start with 1 in the loop below

        return [packet] + (1 ..< packetList.pointee.numPackets).map { _ in
            packet = MIDIPacketNext(&packet).pointee
            return packet
        }
    }

    func onMIDIPacketListReceived(packetList: UnsafePointer<MIDIPacketList>?, srcConnRefCon: UnsafeMutableRawPointer?) {
        print("number of packets: ", packetList?.pointee.numPackets ?? 0)
        let sourceDevice = findOnlineMIDIDeviceFromRefCon(srcConnRefCon)
        let packets = makePacketsFromPacketList(packetList)

        for packet in packets {
			if packet.data.0 == .activeSensing { continue } // Discard MIDI Heartbeat messages
			let (command, key, velocity) = MIDIManager.getMIDIMessageData(from: packet)
			guard let midiMessage = MIDIMessage.from(status: command, data1: key, data2: velocity) else { return }
            onMIDIMessageReceived?(midiMessage, sourceDevice)
        }
    }

    static func getMIDIMessageData(from packet: MIDIPacket) -> (command: UInt8, key: UInt8, velocity: UInt8) {
        let data = packet.data
        let isHighResVelocityMessage = (data.0 == .controlChange) && (data.1 == .highResVelocityPrefix)
        return isHighResVelocityMessage ? (command: data.3, key: data.4, velocity: data.5) // ignore high res data
                                        : (command: data.0, key: data.1, velocity: data.2) // assume normal noteOn/Off
    }

    let onMIDIPacketListReceived: MIDIReadProc = { (packetList, readProcRefCon, srcConnRefCon) in
        let midiManagerSelf = unsafeBitCast(readProcRefCon, to: MIDIManager.self)
        midiManagerSelf.onMIDIPacketListReceived(packetList: packetList, srcConnRefCon: srcConnRefCon)
    }
}


fileprivate extension MIDIEndpointRef {
    var isNetworkSession: Bool {
        return uniqueID == MIDINetworkSession.default().sourceEndpoint().uniqueID
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
