//
//  MIBYHandlers.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 21.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//


@_silgen_name("handleMIDINoteOn")
public func handleMIDINoteOn(_ state: miby_t) {
    guard let userData = state.v else {
        return
    }
    let midiEngine = Unmanaged<MIDIEngine>.fromOpaque(userData).takeUnretainedValue()
    let key = state.buf.0      // XXX: not sure if 0 or 1
    let velocity = state.buf.1 // XXX: not sure if 1 or 2
    let noteMessage = (velocity > 0) ? MIDIMessage.noteOn(key: key, velocity: velocity)
                                     : MIDIMessage.noteOff(key: key)

    midiEngine.onMIDIMessageReceived?(noteMessage, nil, .now)

}

@_silgen_name("handleMIDINoteOff")
public func handleMIDINoteOff(_ state: miby_t) {
    guard let userData = state.v else {
        return
    }
    let key = state.buf.0 // XXX: not sure if 0 or 1

    let midiEngine = Unmanaged<MIDIEngine>.fromOpaque(userData).takeUnretainedValue()
    midiEngine.onMIDIMessageReceived?(MIDIMessage.noteOff(key: key), nil, .now)

}

@_silgen_name("handleMIDISysEx")
public func handleMIDISysEx(_ state: miby_t) {
    guard let userData = state.v else {
        return
    }
    let midiEngine = Unmanaged<MIDIEngine>.fromOpaque(userData).takeUnretainedValue()

    var buffer = state.buf
    let count = Int(state.msglen)

    let data = withUnsafePointer(to: &buffer) { pointerToDataTuple in
        pointerToDataTuple.withMemoryRebound(to: UInt8.self, capacity: count) { pointerToFirstUInt8 in
            Array(UnsafeBufferPointer(start: pointerToFirstUInt8, count: count))
        }
    }

    let device = midiEngine.lastSendingSourceDevice
    midiEngine.onMIDIMessageReceived?(MIDIMessage.systemExclusive(data: data), device, .now)
}
