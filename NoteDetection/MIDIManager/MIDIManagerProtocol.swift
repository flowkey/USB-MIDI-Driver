//
//  MIDIEngineProtocol.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias MIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?) -> Void
public typealias MIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void
