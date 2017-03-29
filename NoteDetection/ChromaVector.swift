//
//  ChromaVector.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.04.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import FlowCommons

// maximum key, until which additional tolerance for low keys as well as an expected chroma value
// for the fifth of a key is calculated. determined through obervation of filterbank during testing
fileprivate let lowKeyBoundary = 48

struct ChromaVector: CustomStringConvertible, Equatable {
    static let size = 12 // a chroma vector always contains 12 values
    static let emptyVector = [Float](repeating: 0, count: ChromaVector.size)

    // Internal datastore, not publicly writable
    fileprivate var vector = ChromaVector.emptyVector

    // Provide read-only access to internal datastore:
    var toRaw: [Float] { return self.vector }

    // ---------------------------------------------------
    // Initialisers

    init () {}

    // The first magnitude in our array needs to be at the 'start' MIDINumber for this to work
    init(from magnitudes: [Float], startingAt start: MIDINumber) {
        self.init()
        for i in 0 ..< magnitudes.count {
            let chromaPos = start + i
            self[chromaPos] += magnitudes[i]
        }
    }

    init(from magnitudes: [Float], startingAt start: MIDINumber, range: CountableClosedRange<MIDINumber>) {
        self.init()
        for i in range {
            self[i] += magnitudes[i - start]
        }
    }

    init(notes: [MusicalNote]) {
        notes.forEach { self.vector[$0.rawValue] = 1 }
    }

    init(from midiKeys: Set<MIDINumber>) {
        midiKeys.forEach { (key) in
            let chromaIndex = key % 12
            self.vector[chromaIndex] = 1
        }
    }

    init?(_ vector: [Float]) {
        if vector.count == ChromaVector.size {
            self.vector = vector
        } else {
            return nil
        }
    }

    // ---------------------------------------------------
    // Instance methods

    var count: Int {
        return self.vector.count
    }

    subscript (index: MusicalNote) -> Float {
        get { return vector[index.rawValue] }
        set { vector[index.rawValue] = newValue }
    }

    subscript (index: Int) -> Float {
        // If someone puts an index out of bounds, wrap it
        // i.e. chroma[12] === chroma[0]
        get { return vector[index % ChromaVector.size]}
        set { vector[(index % ChromaVector.size)] = newValue }
    }

    var description: String {
        return vector.description
    }


    // Return the correlation cosine similarity (a.k.a. Pearson correlation) between two chroma vectors:
    // http://brenocon.com/blog/2012/03/cosine-similarity-pearson-correlation-and-ols-coefficients/

    func similarity(to other: ChromaVector) -> Float {

        var x: Float = 0
        var y: Float = 0
        var z: Float = 0

        var a = self.toRaw
        var b = other.toRaw

        let meanOfA = a.reduce(0.0, +) / Float(ChromaVector.size)
        let meanOfB = b.reduce(0.0, +) / Float(ChromaVector.size)

        for i in (0 ..< ChromaVector.size) {
            a[i] -= meanOfA
            b[i] -= meanOfB
            x += a[i] * b[i]
            y += a[i] * a[i]
            z += b[i] * b[i]
        }

        let result = x / ( sqrt(y) * sqrt(z) )
        return result
    }

    static func composeExpected(from midiKeys: Set<MIDINumber>) -> ChromaVector {
        var vector = ChromaVector()

        for key in midiKeys {
            var valueToAdd: Float = 1.0
            var valueToAddToFifth: Float = 0.0

            if key <= lowKeyBoundary {
                valueToAdd = 0.5
                valueToAddToFifth = computeExpectedValueForFith(of: key)
            }

            vector[key] += valueToAdd
            vector[key+7] += valueToAddToFifth // for a low key: add something to it's fifth ('Quinte', which is 7 semitones up)
        }

        return vector
    }

    static func computeExpectedValueForFith(of key: MIDINumber) -> Float {
//        return pow(1.0 - (Float(key) / Float(lowKeyBoundary)), 2)
//        return sqrt(1.0 - (Float(key) / Float(lowKeyBoundary)))
        return 1.0 - (Float(key) / Float(lowKeyBoundary))
    }

}

func + (lhs: ChromaVector, rhs: ChromaVector) -> ChromaVector {
    var combinedChroma = lhs
    for index in 0 ..< ChromaVector.size {
        combinedChroma[index] += rhs[index]
    }
    return combinedChroma
}

func == (lhs: ChromaVector, rhs: ChromaVector) -> Bool {
    return lhs.toRaw == rhs.toRaw
}
