//
//  NoteRange.swift
//
//  Created by Geordie Jay on 20.08.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

struct NoteRange {
    init(fullRange: ClosedRange<MIDINumber>, lowNoteBoundary: MIDINumber) {
        self.lowNoteBoundary = lowNoteBoundary
        self.fullRange = fullRange
        first = fullRange.first!
        last = fullRange.last!
    }

    let fullRange: ClosedRange<MIDINumber>

    var lowRange: ClosedRange<MIDINumber> {
        return first ... lowNoteBoundary
    }

    var highRange: ClosedRange<MIDINumber> {
        return lowNoteBoundary ... last
    }

    let first: MIDINumber
    let lowNoteBoundary: MIDINumber
    let last: MIDINumber
}
