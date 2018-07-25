//
//  CoreMIDIOutConnection.swift
//  NoteDetection
//
//  Created by flowing erik on 22.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation
import CoreMIDI

public class MIDIOutConnection  {
    let source: MIDIPortRef
    let destination: MIDIEndpointRef
    let refCon: UnsafeMutablePointer<UInt32>

    init(source: MIDIPortRef, destination: MIDIEndpointRef, refCon: UnsafeMutablePointer<UInt32>) {
        self.source = source
        self.destination = destination
        self.refCon = refCon
    }

    public var displayName: String {
        return destination.displayName
    }
}

extension MIDIOutConnection: Hashable {
    public var hashValue: Int { return refCon.hashValue }
    public static func == (lhs: MIDIOutConnection, rhs: MIDIOutConnection) -> Bool {
        return lhs.refCon == rhs.refCon
    }
}
