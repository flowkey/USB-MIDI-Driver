//
//  MIDIOutConnection.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 22.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

public protocol MIDIOutConnection {
    var sourceID: Int { get }
    var destinationID: Int { get }
    func send(_ data: [UInt8])
    func sendSysex(_ data: [UInt8])
}
