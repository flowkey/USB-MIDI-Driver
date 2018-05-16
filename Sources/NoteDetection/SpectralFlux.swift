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

class SpectralFluxOnsetDetection: OnsetDetection {
    var onsetFeatureBuffer = [OnsetFeatureValue](repeating: 0, count: 10)
    var currentThreshold: Float = 0
    var onOnsetDetected: OnsetDetectedCallback?

    private var previousData = [FilterBank.Magnitude]()

    func compute(from inputData: [FilterBank.Magnitude]) -> OnsetFeatureValue {
        defer { // save current spectrum as previous spectrum for next computation
            self.previousData = inputData
        }

        guard previousData.count >= inputData.count else { return 0 }

        let flux: OnsetFeatureValue = inputData.indices.reduce(0, { (previousResult, binNumber) in
            let binDifference: Float = inputData[binNumber] - previousData[binNumber]
            let nonNegativeDifference = max(0, binDifference) // half wave rectification: discard any negative differences

            return previousResult + pow(nonNegativeDifference, 2)
        })

        // normalize
        return sqrt(flux) / OnsetFeatureValue(inputData.count)
    }

    func computeThreshold(from buffer: [OnsetFeatureValue]) -> Float {
        let meanValue = mean(buffer)
        let medianValue = median(buffer)
        let defaultThreshold: OnsetFeatureValue = 0.000005
        return max(meanValue + medianValue, defaultThreshold)
    }
}
