//
//  MIDISource.swift
//  NativePitchDetection
//
//  Created by flowing erik on 21.09.15.
//  Copyright © 2015 flowkey. All rights reserved.
//

public struct MIDIDevice: Equatable, Hashable {
    public let displayName: String
    public let manufacturer: String
    public let model: String
    public let uniqueID: Int
    public let refCon: UnsafeMutableRawPointer

    public var hashValue: Int { return refCon.hashValue }
}

public func == (lhs: MIDIDevice, rhs: MIDIDevice) -> Bool {
    return lhs.refCon == rhs.refCon
}
