//
//  MIDINumber.swift
//  FlowCommons
//
//  Created by flowing erik on 04.10.16.
//  Copyright © 2016 flowkey. All rights reserved.
//

public typealias MIDINumber = Int // like an integer in every way, but extended a bit:

public extension MIDINumber {
    // Use just like an Int:
    // var note: MIDINumber = 36
    // var note = MIDINumber(36)
    
    // Otherwise use one of these initialisers:
    // With a note (C, Dsharp etc) and an octave
    init (note musicalNote: MusicalNote, octave: Int = 4) {
        self.init(((octave + 1) * 12) + musicalNote.rawValue)
    }
    
    // midiNumber is a convenience variable to make it clearer what we're doing internally
    private var midiNumber: Int { return self }

    // The following means that println(MIDINumber(36)) results in "♪C2"
    var description: String {
        return "\(note)\(octave)"
    }
    
    // Allow setting and getting the musical note and octave from our MIDINumber instance:
    
    var note: MusicalNote {
        get { return MusicalNote(rawValue: midiNumber % 12)! }
        set { self = MIDINumber(note: newValue, octave: self.octave) }
    }
    
    var octave: Int {
        get { return (midiNumber / 12) - 1 }
        set { self = MIDINumber(note: self.note, octave: newValue) }
    }
    
    var inHz: Double {
        get { return midiToFrequency(midiNumber) }
    }
}
