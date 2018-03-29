//
//  MIDIEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import JNI
import Dispatch

private weak var midiEngine: MIDIEngine?

@_silgen_name("Java_com_flowkey_notedetection_midi_ApiIndependentMIDIEngine_nativeMidiMessageCallback")
public func onMIDIMessageReceived(env: UnsafeMutablePointer<JNIEnv>, cls: JavaObject, midiData: JavaByteArray, timestamp: JavaLong) {
    let midiDataArray: [UInt8] = jni.GetByteArrayRegion(array: midiData)
    let midiMessages = parseMIDIMessages(from: midiDataArray)
    midiMessages.forEach { midiMessage in
        DispatchQueue.main.async {
            midiMessages.forEach { message in
                switch message {
                case .noteOn, .noteOff: midiEngine?.onMIDIMessageReceived?(message, nil, .now)
                default: break 
                }
            }
        }
    }
}

@_silgen_name("Java_com_flowkey_notedetection_midi_ApiIndependentMIDIEngine_nativeMidiDeviceCallback")
public func onDeviceListChanged(env: UnsafeMutablePointer<JNIEnv>, cls: JavaObject, jMIDIDevices: JavaObjectArray) {
    let numberOfDevices = jni.GetLength(jMIDIDevices)
    var midiDeviceList: Set<MIDIDevice> = []

    for index in (0..<numberOfDevices) {
        guard let jMIDIDevice = try? jni.GetObjectArrayElement(in: jMIDIDevices, at: index),
              let device = try? jMIDIDevice.toMIDIDevice() else {
            fatalError("Could not create midi device from java array element")
        }
        midiDeviceList.insert(device)
    }
    DispatchQueue.main.async {
        midiEngine?.midiDeviceList = midiDeviceList
        midiEngine?.onMIDIDeviceListChanged?(midiDeviceList)
    }
}

fileprivate extension JavaObject {
    func toMIDIDevice() throws -> MIDIDevice {
        let model: String = try jni.GetField("model", from: self)
        let manufacturer: String = try jni.GetField("manufacturer", from: self)
        let id: Int = try jni.GetField("uniqueID", from: self)
        let displayName = model + "/" + manufacturer
        var arbitraryReferenceContext = 0 // dummy

        return MIDIDevice(
            displayName: displayName,
            manufacturer: manufacturer,
            model: model,
            uniqueID: id,
            refCon: &arbitraryReferenceContext
        )
    }
}


class MIDIEngine: JNIObject, MIDIInput, MIDIOutput {

    enum MIDIEngineError: Error {
        case InitError
    }

   convenience init() throws {
        let context = try getMainActivityContext()
        try self.init("com/flowkey/notedetection/midi/ApiIndependentMIDIEngine", arguments: [context])
        midiEngine = self
    }

    fileprivate(set) var midiDeviceList: Set<MIDIDevice> = []
    fileprivate(set) var midiOutConnections: Array<MIDIOutConnection> = []

    deinit {
        print("deiniting MIDIEngine")
        midiEngine = nil
    }

    private(set) var onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?
    func set(onMIDIOutConnectionsChanged callback: MIDIOutConnectionsChangedCallback?) {
        self.onMIDIOutConnectionsChanged = callback
    }

    private(set) var onMIDIMessageReceived: MIDIMessageReceivedCallback?
    func set(onMIDIMessageReceived callback: MIDIMessageReceivedCallback?) {
        self.onMIDIMessageReceived = callback
    }

    private(set) var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    func set(onMIDIDeviceListChanged callback: MIDIDeviceListChangedCallback?) {
        self.onMIDIDeviceListChanged = callback
    }

    private(set) var onSysexMessageReceived: SysexMessageReceivedCallback?
    func set(onSysexMessageReceived callback: SysexMessageReceivedCallback?) {
        self.onSysexMessageReceived = callback
    }
}
