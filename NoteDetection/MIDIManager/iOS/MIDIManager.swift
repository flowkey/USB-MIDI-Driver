//
//  MIDIManager.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

// FIXME: Clean up, then remove swiftlint:disable
// swiftlint:disable file_length

import Foundation
import CoreMIDI

public let MIDIManagerNotificationDeviceChange = "com.flowkey.midimanager.devicechange"

fileprivate extension MIDIEndpointRef {
    var isNetworkSession: Bool {
        return uniqueID == MIDINetworkSession.default().sourceEndpoint().uniqueID
    }
}

public class MIDIManager: MIDIManagerProtocol {
    public static let sharedInstance = MIDIManager()

    public var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback?
    public var onMIDIMessageReceived: OnMIDIMessageReceivedCallback?

    var midiClient = MIDIClientRef()
    var clientInputPort = MIDIPortRef()

    public fileprivate(set) var midiDeviceList: Set<MIDIDevice> = []

    private init() {
        // Create the midi client

        var status: OSStatus = 0

        let clientName = "flowkey" as CFString
        if #available(iOS 9.0, *) {
            status = MIDIClientCreateWithBlock(clientName, &midiClient, notificationBlock)
        } else {
            status = MIDIClientCreate(clientName, notificationProc, nil, &midiClient)
        }

        if status != OSStatus(noErr) {
            print("Error creating MIDI client. Status code: \(status)")
        } else {
            print("MIDI Client created successfully")
        }

        // Create an input port for our client to receive midi messages
        var inputName = "flowkey input port" as CFString
        if #available(iOS 9.0, *) {
            status = MIDIInputPortCreateWithBlock(midiClient, inputName, &clientInputPort, midiReadBlock)
        } else {
            status = MIDIInputPortCreate(midiClient, inputName, midiReadProc, &inputName, &clientInputPort)
        }

        if status != OSStatus(noErr) {
            print("Error creating input port. Status code: \(status)")
        } else {
            print("MIDI Input port created successfully")
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

            // Connect source to our input port...
            // Context is the MIDIDevice in the array:
            // When we receive a MIDI message, we know which device it's coming from
            let status = MIDIPortConnectSource(clientInputPort, source, srcRefCon)

            guard status == OSStatus(noErr) else {
                print("Failed to establish connection. Error code: \(status)")
                break
            }

            midiDeviceList.insert(MIDIDevice(source, srcRefCon: srcRefCon))
            print("Successfully connected \(source.displayName) to \(clientInputPort.displayName)")
        }
    }

    public func disconnect() {
        for sourceIndex in 0 ..< MIDIGetNumberOfSources() {
            let source = MIDIGetSource(sourceIndex)

            // only disconnect if there is a connectionUniqueID
            // according to core midi doc, connectionUniqueID is 0 if there is no connection
            if source.connectionUniqueID != 0 {
                let status = MIDIPortDisconnectSource(clientInputPort, source)

                guard status == OSStatus(noErr) else {
                    print("Failed to disconnect. Error code: \(status)")
                    continue
                }

                print("Successfully disconnected \(source.displayName) from \(clientInputPort.displayName)")

            } else {
                print("\(source.displayName) has no connectionUniqueID (not connected)")
            }
        }
        midiDeviceList = []
    }


    /*
     * MARK: MIDI Notification (Device added / removed)
     */

    func notificationBlock (_ notificationPtr: UnsafePointer<MIDINotification>) {
        let msgId = notificationPtr.pointee.messageID
        if msgId == .msgObjectAdded || msgId == .msgObjectRemoved || msgId == .msgPropertyChanged {
            connect()    // refresh sources when something changed

            DispatchQueue.main.async {
                NotificationCenter.default
                    .post(name: Notification.Name(rawValue: MIDIManagerNotificationDeviceChange), object: nil)
            }
        }
    }

    let notificationProc: MIDINotifyProc = { (notificationPtr: UnsafePointer<MIDINotification>, _) in
        MIDIManager.sharedInstance.notificationBlock(notificationPtr)
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

    func midiReadBlock (_ packetList: UnsafePointer<MIDIPacketList>?, srcConnRefCon: UnsafeMutableRawPointer?) {

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

    let midiReadProc: MIDIReadProc = {(
        packetList: UnsafePointer<MIDIPacketList>,
        readProcRefCon: UnsafeMutableRawPointer?,
        srcConnRefCon: UnsafeMutableRawPointer?) in
            MIDIManager.sharedInstance.midiReadBlock(packetList, srcConnRefCon: srcConnRefCon)
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
