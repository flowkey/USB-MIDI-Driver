//
//  MIDIInput.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias MIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?, Timestamp) -> Void
public typealias MIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void

protocol MIDIInput {
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?)
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?)
}
