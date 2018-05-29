//
//  MIDIOutConnectionAndroid.swift
//  NoteDetection
//
//  Created by flowing erik on 22.03.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

// MIDIOutConnection stub for Android, to be implemented when we support Yamaha Light Control in Android
public class MIDIOutConnection {
    private let refCon: UnsafeMutablePointer<UInt32>
    
    init(refCon: UnsafeMutablePointer<UInt32>) {
        self.refCon = refCon
    }
}

extension MIDIOutConnection {
    public var displayName: String {
        // TODO: Implement Me
        return "MIDIOutConnection Stub"
    }

    public func send(messages: [[UInt8]]) {
        // TODO: Implement Me
    }
}

extension MIDIOutConnection: Equatable {
    public static func == (lhs: MIDIOutConnection, rhs: MIDIOutConnection) -> Bool {
        return lhs.refCon == rhs.refCon
    }
}
