//
//  NoteEvent.swift
//
//  Created by Geordie Jay on 20.10.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

public struct NoteEvent {
    /// x position within the sheet, in pixels
    public let x: Double

    /// The time in miliseconds at which the event is found in its corresponding video
    public let t: Double

    /// The time in miliseconds between this event and the next one
    internal(set) public var timeToNext: Double

    /// All of this event's notes for the left hand (`notes` is calculated from this)
    fileprivate let notesL: Set<Note>

    /// All of this event's notes for the right hand (`notes` is calculated from this)
    fileprivate let notesR: Set<Note>

    /// The publicly accessible notes, set depending on which hands are selected
    /// hands is set via SyncState.withHands()
    fileprivate(set) public var notes: Set<MIDINumber>

    /// The names of the currently played notes
    fileprivate(set) public var noteNames: [String]

    // The indexes to light up, based on notes
    fileprivate(set) public var lightningKeyIndexes: [Int]
}

extension NoteEvent {
    public struct Note: Hashable {
        public let key: Int
        public let name: String

        public var hashValue: Int { return key.hashValue }
        public static func == (lhs: Note, rhs: Note) -> Bool {
            return lhs.key == rhs.key
        }
    }
}

extension NoteEvent {
    public init (x: Double, t: Double, notesL: [Note], notesR: [Note]) {
        self.x = x
        self.t = t
        self.timeToNext = 0 // FIXME: This value is wrong here, it needs to be calculated on init

        let notesL = notesL.sorted(by: { $0.key < $1.key })
        let notesR = notesR.sorted(by: { $0.key < $1.key })
        //let allNotes = (notesL + notesR).sorted(by: { $0.key < $1.key })

        self.notesL = Set(notesL)
        self.notesR = Set(notesR)

        // The parts that vary depending on the selected hand should always be set by our convenience functions
        // So they start off empty
        self.notes = Set()
        self.noteNames = []
        self.lightningKeyIndexes = []

        // Set them here:
        let eventWithBothHands = withHands(left: true, right: false)
        self.notes = eventWithBothHands.notes
        self.noteNames = eventWithBothHands.noteNames
        self.lightningKeyIndexes = eventWithBothHands.lightningKeyIndexes
    }

    public func withHands(left: Bool, right: Bool) -> NoteEvent {
        var newEvent = self
        let notes = getNotesForHands(left: left, right: right).sorted(by: { $0.key < $1.key })
        newEvent.notes = Set(notes.map({$0.key}))
        newEvent.noteNames = notes.map({$0.name})
        newEvent.lightningKeyIndexes = makeLightningKeyIndexes(from: notes)

        return newEvent
    }

    private func getNotesForHands(left: Bool, right: Bool) -> Set<Note> {
        if left  && !right { return notesL }
        if right && !left  { return notesR }
        return notesL.union(notesR)
    }
}

typealias LightningKeyIndex = Int
fileprivate func makeLightningKeyIndexes(from notes: [NoteEvent.Note]) -> [LightningKeyIndex] {
    let numberOfMidiNotesBelowLowestPianoKey = 21
    return notes.map {
        let index = $0.key - numberOfMidiNotesBelowLowestPianoKey
        assert(index >= 0)
        return index
    }
}


extension NoteEvent.Note: ExpressibleByIntegerLiteral {
    // For fixtures etc:
    public init(integerLiteral value: Int) {
        self.key = value
        self.name = "?"
    }
}
