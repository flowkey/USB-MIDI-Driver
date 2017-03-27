//
//  NoteDetectionData.swift
//  FlowCommons
//
//  Created by flowing erik on 05.10.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

public typealias JSONDict = [String:AnyObject]

// maximum key, until which additional tolerance for low keys as well as an expected chroma value
// for the fifth of a key is calculated. determined through obervation of filterbank during testing
fileprivate let lowKeyBoundary = 48

public struct NoteDetectionData {
    /// Contains 12 values between 0 and 1, but typically 0 or 1
    public let expectedChroma: ChromaVector

    /// For similarityThreshold, e.g. for chords
    public let tolerance: Float

    /// Stores the midi number of every expected note
    public let notes: Set<MIDINumber>
}

extension NoteDetectionData: CustomDebugStringConvertible {
    // Make our notes printable in the debugger:
    public var debugDescription: String {
        return "\nNotes: \(notes.map { $0.description }) == MIDINumbers: \(notes) -- " +
                "Expected chroma: \(expectedChroma.description) -- " +
                "Tolerance: \(tolerance)"
    }
}

public extension NoteDetectionData {
    init(from: NoteEvent) {
        self.notes = from.notes
        self.tolerance = NoteDetectionData.calculateTolerance(for: notes)
        self.expectedChroma = ChromaVector.composeExpected(from: notes)
    }

    static func calculateTolerance(for notes: Set<MIDINumber>) -> Float {
        let chordTolerance: Float = Float((notes.count - 1)) * 0.03

        var lowKeyTolerance: Float = 0
        for key in notes {
            lowKeyTolerance += (key <= lowKeyBoundary) ? 0.03 : 0.0
        }

        return min(chordTolerance + lowKeyTolerance, 0.10)
    }

    init? (fromJSONDict event: JSONDict) {
        if
            let chromaArray = event["expChroma"] as? [Float],
            let chroma = ChromaVector(chromaArray),
            let tolerance = event["tolerance"] as? Float,
            let notesArray = event["notes"] as? [JSONDict]
        {
            let notes = notesArray.reduce([MIDINumber]()) {
                if let midiNote = $1["key"] as? MIDINumber {
                    return $0 + [midiNote]
                } else {
                    return $0
                }
                }.sorted(by: <)

            if notes.count > 0 {
                self.expectedChroma = chroma
                self.tolerance = tolerance
                self.notes = Set(notes)
            } else {
                print("FAIL: Your event contains no notes")
                return nil
            }
        } else {
            print("Couldn't reconstruct the noteEvent based on your JSON input!")
            return nil
        }
    }
}
