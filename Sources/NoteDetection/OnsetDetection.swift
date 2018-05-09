//
//  OnsetDetection.swift
//  NativePitchDetection
//
//  Created by flowing erik on 31.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

public typealias OnsetDetectedCallback = (Timestamp) -> Void
typealias OnsetData = (featureValue: Float, threshold: Float, onsetDetected: Bool)

public class OnsetDetection {
    private let onsetFeature = SpectralFlux() // or RMS()
    private var onsetFeatureBuffer: [Float]
    private var currentThreshold: Float = 0
    var onOnsetDetected: OnsetDetectedCallback?

    init() {
        self.onsetFeatureBuffer = [Float](repeating: 0.0, count: onsetFeature.defaultFeatureBufferSize)
    }

    func run(inputData: [Float]) -> OnsetData {
        let currentFeatureValue = onsetFeature.compute(from: inputData)
		onsetFeatureBuffer.remove(at: 0)
        onsetFeatureBuffer.append(currentFeatureValue)
        currentThreshold = onsetFeature.computeThreshold(from: onsetFeatureBuffer)

        let onsetDetected: Bool
        if currentBufferIsAPeak {
            onsetDetected = true
            onOnsetDetected?(.now)
        } else {
            onsetDetected = false
        }

        return (currentFeatureValue, currentThreshold, onsetDetected)
    }

    // MARK: Peak Picking functions

    // calls all the functions which help to find a peak
    fileprivate var currentBufferIsAPeak: Bool {
        return atLocalMaximum && isAboveThreshold(atNegativeIndex: 2)
    }

    // simple check for local maximum within the last 3 elements of onsetFeatureBuffer
    fileprivate var atLocalMaximum: Bool {
        let bufferSlice = [Float](onsetFeatureBuffer[onsetFeatureBuffer.count - 3 ..< onsetFeatureBuffer.count])
        return isLocalMaximum(amplitudes: bufferSlice, centreIndex: 1)
    }

    // check if element at position [bufferlength - reverseIndex] is bigger than current threshold
    fileprivate func isAboveThreshold(atNegativeIndex reverseIndex: Int) -> Bool {
        return onsetFeatureBuffer[onsetFeatureBuffer.count - reverseIndex] > self.currentThreshold
    }
}

func isLocalMaximum(amplitudes: [Float], centreIndex: Int) -> Bool {
    return isLocalExtreme(findMinimum: false, numArray: amplitudes, checkPosition: centreIndex)
}

func isLocalMinimum(amplitudes: [Float], centreIndex: Int) -> Bool {
    return isLocalExtreme(findMinimum: true, numArray: amplitudes, checkPosition: centreIndex)
}

func isLocalExtreme(findMinimum: Bool, numArray: [Float], checkPosition: Int) -> Bool {
    // enumerate gives us a tuple like this: (index, value):
    return numArray.enumerated().reduce(true) { (isTrueSoFar, cur: (i: Int, value: Float)) -> Bool in

        if !isTrueSoFar { return false }

        var shouldBeDecreasing: Bool {
            return findMinimum ? (cur.i < checkPosition) : (cur.i >= checkPosition)
        }

        // Avoid array out of bounds:
        if cur.i == numArray.count - 1 {
            return isTrueSoFar
        } else if shouldBeDecreasing {
            // when entering a trough, volume of next block should be less than the current one
            return isTrueSoFar && numArray[cur.i + 1] < cur.value
        } else {
            // coming out of the trough, volume should be increasing from here..
            return isTrueSoFar && numArray[cur.i + 1] > cur.value
        }
    }
}
