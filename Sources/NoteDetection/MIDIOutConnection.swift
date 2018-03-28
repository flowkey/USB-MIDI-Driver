//
//  MIDIOutConnection.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 22.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

public protocol MIDIOutConnection {
    var displayName: String { get }
    func send(messages: [[UInt8]])
    func sendSysex(_ data: [UInt8])
}
