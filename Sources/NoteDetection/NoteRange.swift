//
//  NoteRange.swift
//
//  Created by Geordie Jay on 20.08.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

public struct NoteRange {
    public init(fullRange: CountableClosedRange<MIDINumber>, lowNoteBoundary: MIDINumber) {
        self.lowNoteBoundary = lowNoteBoundary
        first = fullRange.first!
        last = fullRange.last!
    }

    public var fullRange: CountableClosedRange<MIDINumber> {
        return first ... last
    }

    public var lowRange: CountableClosedRange<MIDINumber> {
        return first ... lowNoteBoundary
    }

    public var highRange: CountableClosedRange<MIDINumber> {
        return lowNoteBoundary ... last
    }

    public let first: MIDINumber
    public let lowNoteBoundary: MIDINumber
    public let last: MIDINumber
}

extension NoteRange {
    public static let standard = NoteRange(
        fullRange: MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 8),
        lowNoteBoundary: MIDINumber(note: .d, octave: 5)
    )
}
