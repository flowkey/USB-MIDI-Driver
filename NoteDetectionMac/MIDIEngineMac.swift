//
//  MIDIEngineMac.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation

final class MIDIEngine: MIDIInput {
    var midiDeviceList: Set<MIDIDevice> = []

    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {}
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?) {}
}
