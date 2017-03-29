//
//  MIDIManagerProtocol.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias OnMIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?) -> Void
public typealias OnMIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void

protocol MIDIManagerProtocol {
    func connect()
    func disconnect()

    var onMIDIMessageReceived: OnMIDIMessageReceivedCallback? { get set }
    var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback? { get set }
}
