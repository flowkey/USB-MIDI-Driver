//
//  ChromaVector.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 17.04.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import Foundation

// maximum key, until which additional tolerance for low keys as well as an expected chroma value
// for the fifth of a key is calculated. determined through obervation of filterbank during testing
fileprivate let lowKeyBoundary = 48

struct ChromaVector: CustomStringConvertible, Equatable {
    static let size = 12 // a chroma vector always contains 12 values
    static let emptyVector = [Float](repeating: 0, count: ChromaVector.size)

    // Internal datastore, not publicly writable
    fileprivate var backingStore = ChromaVector.emptyVector

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

    init?(_ vector: [Float]) {
        if vector.count == ChromaVector.size {
            self.backingStore = vector
        } else {
            return nil
        }
    }

    // ---------------------------------------------------
    // Instance methods

    var count: Int {
        return self.backingStore.count
    }

    subscript (index: MusicalNote) -> Float {
        get { return backingStore[index.rawValue] }
        set { backingStore[index.rawValue] = newValue }
    }

    subscript (index: Int) -> Float {
        // If someone puts an index out of bounds, wrap it
        // i.e. chroma[12] === chroma[0]
        get { return backingStore[index % ChromaVector.size]}
        set { backingStore[(index % ChromaVector.size)] = newValue }
    }

    var description: String {
        return backingStore.description
    }


    // Return the correlation cosine similarity (a.k.a. Pearson correlation) between two chroma vectors:
    // http://brenocon.com/blog/2012/03/cosine-similarity-pearson-correlation-and-ols-coefficients/

    func similarity(to other: ChromaVector) -> Float {
        var x: Float = 0
        var y: Float = 0
        var z: Float = 0

        var a = self
        var b = other

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

    /// Takes a set of MIDINumbers and composes the ChromaVector we expect to see given those notes.
    /// This includes adding values to the fifth harmonic of lower notes.
    init?(composeFrom midiKeys: Set<MIDINumber>?) {
        guard let midiKeys = midiKeys else { return nil }
        var vector = ChromaVector()

        for key in midiKeys {
            var valueToAdd: Float = 1.0
            var valueToAddToFifth: Float = 0.0

            if key <= lowKeyBoundary {
                valueToAdd = 0.5
                valueToAddToFifth = ChromaVector.computeExpectedValueForFifth(of: key)
            }

            vector[key] += valueToAdd
            vector[key+7] += valueToAddToFifth // for low keys: add something to its fifth ('Quinte', 7 semitones up)
        }

        self = vector
    }

    static func computeExpectedValueForFifth(of key: MIDINumber) -> Float {
        return 1.0 - (Float(key) / Float(lowKeyBoundary))
    }

    static func + (lhs: ChromaVector, rhs: ChromaVector) -> ChromaVector {
        var combinedChroma = lhs
        for index in 0 ..< ChromaVector.size {
            combinedChroma[index] += rhs[index]
        }
        return combinedChroma
    }

    static func == (lhs: ChromaVector, rhs: ChromaVector) -> Bool {
        return lhs.backingStore == rhs.backingStore
    }
}

extension ChromaVector: Collection {
    func index(after i: Int) -> Int { return i + 1 }
    var startIndex: Int { return 0 }
    var endIndex: Int { return 11 }
}
