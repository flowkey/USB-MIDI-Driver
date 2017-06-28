//
//  MIDIEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

class MIDIEngine: MIDIInput {
    var onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?
    var onMIDIMessageReceived: MIDIMessageReceivedCallback?

    public private(set) var midiDeviceList: Set<MIDIDevice> = []

    public init() throws {
        connect()
    }

    deinit {
        print("deiniting MIDIEngine")
    }

    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?) {
        self.onMIDIMessageReceived = onMIDIMessageReceived
    }

    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {
        self.onMIDIDeviceListChanged = onMIDIDeviceListChanged
    }


    public func connect() {
        disconnect()

    }

    public func disconnect() {
        midiDeviceList = []
    }
}
