//
//  MIDIInput.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias MIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?, Timestamp) -> Void
public typealias MIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void

protocol MIDIInput: class {
    var midiDeviceList: Set<MIDIDevice> { get }
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?)
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?)
}

public typealias MIDIOutConnectionsChangedCallback = ([MIDIOutConnection]) -> Void

protocol MIDIOutput: class {
    var midiOutConnections: [MIDIOutConnection] { get }
    func set(onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?)
}
