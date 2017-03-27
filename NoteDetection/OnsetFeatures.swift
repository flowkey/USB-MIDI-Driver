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
//

// MARK: Onset Feature Protocol

/// Could be Spectral Flux, HFC, simple RMS or whatever
protocol OnsetFeature {

    var defaultThreshold: Float { get }
    var defaultFeatureBufferSize: Int { get }

    func compute(inputData: [Float]) -> Float
    func updateThreshold(buffer: [Float]) -> Float
}


// MARK: Spectral Flux

public class SpectralFlux: OnsetFeature {

    var previousData: [Float] = [Float]()

    var defaultThreshold: Float = 0.000005
    var defaultFeatureBufferSize: Int = 10

    func compute(inputData filterbankMagnitudes: [Float]) -> Float {

        var flux: Float = 0

        defer {
            // save current spectrum as previous spectrum for next computation
            self.previousData = filterbankMagnitudes
        }

        guard previousData.count >= filterbankMagnitudes.count else { return 0 }

        for i in 0 ..< filterbankMagnitudes.count {

            var tempSf: Float = filterbankMagnitudes[i] - previousData[i] //calculate difference of current bin between current and last spectrum


            // 'half wave rectification': discard any negative difference (set to zero)
            // tempSf = (tempSf + abs(tempSf)) / 2 // math
            // if tempSf < 0 { tempSf = 0 }         // logic
            if tempSf < 0 { continue }              // smart logic


            //square and sum up
            tempSf *= tempSf
            flux += tempSf

        }

        // normalize
        flux = sqrt(flux)
        flux /= Float(filterbankMagnitudes.count)

        return flux
    }

    func updateThreshold(buffer: [Float]) -> Float {
        let meanValue = mean(buffer)
        let medianValue = median(buffer)

        // adjust this formula depending on onset feature and buffer size
        let threshold = max(meanValue + medianValue, self.defaultThreshold)

        return threshold
    }
}


// MARK: Root Mean Square

protocol RMS: OnsetFeature {}
extension RMS {
    func compute(inputData rawAudio: [Float]) -> Float {
        return rootMeanSquare(rawAudio)
    }
    func updateThreshold(buffer: [Float]) -> Float {

        let medianValue = median(buffer)

        // adjust this formula depending on onset feature and buffer size
        let threshold = max(medianValue, self.defaultThreshold)

        return threshold
    }
}

class RMSTimeDomain: RMS {
    let defaultThreshold: Float = 0.005
    let defaultFeatureBufferSize: Int = 10
}

class RMSFilterbank: RMS {
    let defaultThreshold: Float = 0.00025
    let defaultFeatureBufferSize: Int = 10
}
