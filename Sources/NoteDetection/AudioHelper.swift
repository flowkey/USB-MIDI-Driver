//
//  AudioHelper.swift
//
//  Created by flowing erik on 04.10.16.
//  Copyright © 2016 flowkey. All rights reserved.
//


import Foundation

let midiNumberForA = MIDINumber(69)

/*
 * MARK: conversion between linear values and decibel (for amplitudes, therefore 20 or 0.05 as factors)
 */
public func linearToDecibel(_ linearValue: Float, referenceValue: Float = 1) -> Float{
    return 20 * log10(linearValue / referenceValue)
}

public func decibelToLinear(_ decibelValue: Float, referenceValue: Float = 1) -> Float {
    return pow(10, (decibelValue * 0.05)) * referenceValue
}


/*
 * MARK: conversion between bin and frequency of an FFT (needs sampleRate and fftSize)
 */
public func getSpectrumBinOf(_ frequency: Float, frequencyRatio: Float, sampleRate: Float, fftSize: Int) -> Int {
    let first: Float = frequencyRatio * frequency * Float(fftSize)
    let second: Float = first / sampleRate
    return lround(Double(second))
}

public func getFrequencyOf(_ spectrumBin: Int, sampleRate: Float, fftSize: Int) -> Float {
    return Float(spectrumBin) * (sampleRate / Float(fftSize))
}


/*
 * MARK: conversion between cent and frequency ratio
 */
public func centToFrequencyRatio(_ cent: Float) -> Float {
    return pow(2, cent / 100 / 12)
}

public func frequencyRatioToCent(_ ratio: Float) -> Float {
    return 1200 * log2(ratio)
}


/*
 * MARK: conversion between midi number and frequency
 */
public func midiToFrequency(_ midiNumber: MIDINumber, tuningRef: Double = 440) -> Double {
    return tuningRef * pow(2, Double(midiNumber - midiNumberForA) / 12)
}

public func frequencyToMidi(_ frequency: Double, tuningRef: Double = 440) -> MIDINumber {
    return lround(Double(midiNumberForA) + 12 * log2(frequency / tuningRef))
}
