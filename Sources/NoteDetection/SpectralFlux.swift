//
//  SpectralFlux.swift
//  NativePitchDetection
//
//  Created by flowing erik on 01.04.15.
//  Copyright (c) 2015 Geordie Jay. All rights reserved.
//
//  Info about Spectral Flux:
//  Formula: http://www.dafx.ca/proceedings/papers/p_133.pdf
//  Example Matlab Implementation: http://www.audiocontentanalysis.org/code/audio-features/spectral-flux/


import Foundation

class SpectralFlux {
    private var previousData: [Float] = [Float]()
    private let defaultThreshold: Float = 0.000005
    let defaultFeatureBufferSize: Int = 10


    func compute(from inputData: [Float]) -> Float {
        defer { // save current spectrum as previous spectrum for next computation
            self.previousData = inputData
        }

        guard previousData.count >= inputData.count else { return 0 }

        let flux: Float = inputData.indices.reduce(0, { (previousResult, binNumber) in
            let binDifference: Float = inputData[binNumber] - previousData[binNumber]
            let nonNegativeDifference = max(0, binDifference) // half wave rectification: discard any negative differences

            return previousResult + pow(nonNegativeDifference, 2)
        })

        // normalize
        return sqrt(flux) / Float(inputData.count)
    }

    func computeThreshold(from buffer: [Float]) -> Float {
        let meanValue = mean(buffer)
        let medianValue = median(buffer)
        return max(meanValue + medianValue, self.defaultThreshold)
    }
}
