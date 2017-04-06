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
    public var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    public var onMIDIMessageReceived: MIDIMessageReceivedCallback?

    var midiClient = MIDIClientRef()
    var inputPort = MIDIPortRef()

    public private(set) var midiDeviceList: Set<MIDIDevice> = []

    public init() throws {
        try MIDIClientCreateWithBlock(
            "flowkey" as CFString, &midiClient, onMIDIDeviceChanged
        ).throwOnError()

        try MIDIInputPortCreateWithBlock(
            midiClient, "flowkey input port" as CFString, &inputPort, onMIDIPacketListReceived
        ).throwOnError()

        connect()
    }

    deinit {
        print("deiniting MIDIEngine")
    }

    // ios9 bug - keep ref to prevent bad_exec error on removal of the device
    // details: http://stackoverflow.com/questions/32686214/removeconnection-results-in-exc-bad-access
    private var oldNetworkMIDIConnections: Set<MIDINetworkConnection> = []

    private func networkSessionIsConnected() -> Bool {
        let activeConnections = MIDINetworkSession.default().connections()
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
                try MIDIPortConnectSource(inputPort, source, srcRefCon).throwOnError()
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

            try? MIDIPortDisconnectSource(inputPort, source).throwOnError()
        }

        midiDeviceList = []
    }


    // MARK: MIDI Notification (Device added / removed)

    func onMIDIDeviceChanged(notification: UnsafePointer<MIDINotification>) {
        switch notification.pointee.messageID {
        case .msgObjectAdded, .msgObjectRemoved, .msgPropertyChanged:
            connect() // refresh sources when something changed
            DispatchQueue.main.async { self.onMIDIDeviceListChanged?(self.midiDeviceList) }
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

    func onMIDIPacketListReceived(packetList: UnsafePointer<MIDIPacketList>?, srcConnRefCon: UnsafeMutableRawPointer?) {
        let sourceDevice = midiDeviceList.first { $0.refCon == srcConnRefCon }
        let packets = makePacketsFromPacketList(packetList)

        for packet in packets {
			if packet.data.0 == .activeSensing { continue } // Discard MIDI Heartbeat messages
            guard let midiMessage = MIDIMessage(from: packet) else { return }
            onMIDIMessageReceived?(midiMessage, sourceDevice)
        }
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
