//
//  NoteDetectionData.swift
//
//  Created by flowing erik on 05.10.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

typealias JSONDict = [String:AnyObject]

// maximum key, until which additional tolerance for low keys as well as an expected chroma value
// for the fifth of a key is calculated. determined through obervation of filterbank during testing
fileprivate let lowKeyBoundary = 48

public protocol DetectableNoteEvent {
    /// Stores the midi number of every expected note
    var notes: Set<MIDINumber> { get }
}

private let maxAllowedTolerance = Float(0.10)

extension Set where Element == MIDINumber {
    func calculateTolerance() -> Float {
        let chordTolerance = Float(count - 1) * 0.03
        let lowKeyTolerance = reduce(0.0, { tolerance, key -> Float in tolerance + (key <= lowKeyBoundary ? 0.03 : 0.0) })
        return Swift.min(chordTolerance + lowKeyTolerance, maxAllowedTolerance)
    }
}
