//
//  NativePitchDetectionTests.swift
//  NativePitchDetectionTests
//
//  Created by Geordie Jay on 04.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import XCTest
import FlowCommons
import Accelerate

@testable import NoteDetection

class NativePitchDetectionTests: XCTestCase {

    let sampleRate: Double = 44100
    let bufferLength: Int = 1024

    let midiNumberForA = MIDINumber(69)
    let frequencyForA: Double = 440

    // MARK: test functions

    func testChromaVectorSimilarity() {
        XCTAssert((ChromaVector([Float](repeating: 0, count: 12))! == ChromaVector()),
            "An empty Chroma Vector inited with () should equal one created from a [Float]")

        let chromaVectorWithG = ChromaVector(notes: [.g])
        XCTAssertEqualWithAccuracy(chromaVectorWithG.similarity(to: chromaVectorWithG), 1.0, accuracy: 0.000001,
            "Equal chroma vectors should have a 1.0 similarity with one another")
    }

    func testMIDIConversion() {
        XCTAssertEqual(midiNumberForA.inHz, frequencyForA)
    }


    func testFilterbankMapping() {
        let sineWave = createSineWave(bufferLength, f: midiNumberForA.inHz, fs: Double(sampleRate))
        let audioNoteDetection = AudioNoteDetection()

        for _ in 0...100 {
            audioNoteDetection.process(audio: sineWave)
        }

        let magnitudes = audioNoteDetection.filterbank.magnitudes

        let actualMaxMagnitudeIndex = magnitudes.index(of: max(magnitudes))

        let desiredMaxMagnitudeIndex = midiNumberForA - audioNoteDetection.filterbank.noteRange.lowerBound

        XCTAssertEqual(actualMaxMagnitudeIndex, desiredMaxMagnitudeIndex)

    }

    func testChromaMapping() {
        let sineWave = createSineWave(bufferLength, f: midiNumberForA.inHz, fs: Double(sampleRate))
        let audioProcessor = AudioNoteDetection()

        for _ in 0...100 {
            audioProcessor.process(audio: sineWave)
        }

        let chromaVector = audioProcessor.chroma(.highAndLow)
        let actualMaxElementIndex = chromaVector.toRaw.index(of: max(chromaVector.toRaw))
        let desiredMaxElementIndex = midiNumberForA % 12
        XCTAssertEqual(actualMaxElementIndex, desiredMaxElementIndex)
    }


    // MARK: helper functions

    // creates an audio frame in the form of an sine wave
    func createSineWave(_ n: Int, f: Double, fs: Double, amp: Double = 1) -> [Float] {
        var wave: [Float] = [Float](repeating: 0, count: n)

        for index in 0 ..< wave.count {
            wave[index] = Float(applySine(Double(index), f: f, fs: fs, amp: amp))
        }

        return wave
    }

    // returns an amplitude value for x for a given frequency f and samplerate fs, amplitude always 1
    func applySine(_ x: Double, f: Double, fs: Double, amp: Double = 1) -> Double {
        return amp * NoteDetection.sin(2 * NoteDetection.M_PI * f/fs * x)
    }
}
