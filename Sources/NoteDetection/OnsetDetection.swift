//
//  OnsetDetection.swift
//  NativePitchDetection
//
//  Created by flowing erik on 31.03.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//

public typealias OnsetDetectedCallback = (Timestamp) -> Void

public class OnsetDetection {
    let onsetFeature: OnsetFeature
    var onsetFeatureBuffer: [Float]
    var currentThreshold: Float
    var onOnsetDetected: OnsetDetectedCallback?

    init(feature: OnsetFeature) {
        self.onsetFeature = feature
        self.onsetFeatureBuffer = [Float](repeating: 0.0, count: onsetFeature.defaultFeatureBufferSize)
        self.currentThreshold = onsetFeature.defaultThreshold
    }

    // incoming audioData is in time or frequency domain, depending on onsetFeature
    func run(_ audioData: [Float], filterbankMagnitudes: [Float]) -> (featureValue: Float, threshold: Float, wasDetected: Bool) {
        var onsetDetected = false

        var currentFeatureValue: Float = 0.0
        if onsetFeature is SpectralFlux {
            currentFeatureValue = onsetFeature.compute(inputData: filterbankMagnitudes)
        } else if onsetFeature is RMSFilterbank {
            currentFeatureValue = onsetFeature.compute(inputData: filterbankMagnitudes)
        } else if onsetFeature is RMSTimeDomain {
            currentFeatureValue = onsetFeature.compute(inputData: audioData)
        } else {
            assertionFailure("Type of onsetFeature not handled. ")
        }

		onsetFeatureBuffer.remove(at: 0)
        onsetFeatureBuffer.append(currentFeatureValue)

        currentThreshold = onsetFeature.updateThreshold(buffer: onsetFeatureBuffer)

        if currentBufferIsAPeak {
            onsetDetected = true
            onOnsetDetected?(.now)
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
