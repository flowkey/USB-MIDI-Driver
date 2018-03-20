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
    let midiMessages = jni.GetByteArrayRegion(array: midiData).toMIDIMessages()
    DispatchQueue.main.async {
        midiMessages.forEach { midiMessage in
            midiEngine?.onMIDIMessageReceived?(midiMessage, nil, Timestamp(timestamp))
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


class MIDIEngine: JNIObject, MIDIInput {

    enum MIDIEngineError: Error {
        case InitError
    }

   convenience init() throws {
        let context = try getMainActivityContext()
        try self.init("com/flowkey/notedetection/midi/ApiIndependentMIDIEngine", arguments: [context])
        midiEngine = self
    }

    fileprivate(set) var midiDeviceList: Set<MIDIDevice> = []

    deinit {
        print("deiniting MIDIEngine")
        midiEngine = nil
    }

    var onMIDIMessageReceived: MIDIMessageReceivedCallback?
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?) {
        self.onMIDIMessageReceived = onMIDIMessageReceived
    }

    var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {
        self.onMIDIDeviceListChanged = onMIDIDeviceListChanged
    }
}
