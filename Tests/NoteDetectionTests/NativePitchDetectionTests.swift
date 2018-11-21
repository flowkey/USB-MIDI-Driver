//
//  NativePitchDetectionTests.swift
//  NativePitchDetectionTests
//
//  Created by Geordie Jay on 04.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

import XCTest
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

        let chromaVectorWithG = ChromaVector([0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0])! // G
        XCTAssertEqual(chromaVectorWithG.similarity(to: chromaVectorWithG), 1.0, accuracy: 0.000001,
            "Equal chroma vectors should have a 1.0 similarity with one another")
    }

    func testMIDIConversion() {
        XCTAssertEqual(midiNumberForA.inHz, frequencyForA)
    }


    func testFilterbankMapping() {
        let sineWave = createSineWave(bufferLength, freq: midiNumberForA.inHz, sampleRate: Double(sampleRate))
        let audioNoteDetection = AudioNoteDetector(sampleRate: Double(sampleRate))

        for _ in 0...100 {
            audioNoteDetection.process(audio: sineWave, at: 0)
        }

        let magnitudes = audioNoteDetection.filterbank.magnitudes

        let actualMaxMagnitudeIndex = magnitudes.index(of: max(magnitudes))

        let desiredMaxMagnitudeIndex = midiNumberForA - audioNoteDetection.pitchDetection.noteRange.lowRange.lowerBound

        XCTAssertEqual(actualMaxMagnitudeIndex, desiredMaxMagnitudeIndex)

    }

    func testChromaMapping() {
        let testedNote = midiNumberForA
        let sineWave = createSineWave(bufferLength, freq: testedNote.inHz, sampleRate: Double(sampleRate))
        let noteDetector = AudioNoteDetector(sampleRate: Double(sampleRate))

        for _ in 0...100 {
            noteDetector.process(audio: sineWave, at: 0)
        }

        let chromaVector = noteDetector.pitchDetection.chroma(from: noteDetector.filterbank.magnitudes)
        let actualMaxElementIndex = chromaVector.index(of: max(chromaVector))
        let desiredMaxElementIndex = testedNote % 12
        XCTAssertEqual(actualMaxElementIndex, desiredMaxElementIndex)
    }


    // MARK: helper functions

    // creates an audio frame in the form of an sine wave
    func createSineWave(_ count: Int, freq: Double, sampleRate: Double, amp: Double = 1) -> [Float] {
        var wave: [Float] = [Float](repeating: 0, count: count)

        for index in 0 ..< wave.count {
            wave[index] = Float(applySine(Double(index), freq: freq, sampleRate: sampleRate, amp: amp))
        }

        return wave
    }

    // returns an amplitude value for x for a given frequency f and samplerate fs, amplitude always 1
    func applySine(_ value: Double, freq: Double, sampleRate: Double, amp: Double = 1) -> Double {
        return amp * Foundation.sin(2 * Double.pi * freq/sampleRate * value)
    }
}
