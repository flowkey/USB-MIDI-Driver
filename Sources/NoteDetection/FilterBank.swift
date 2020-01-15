//
//  Filterbank.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 18.03.15.
//  Copyright (c) 2015 flowkey. All rights reserved.
//

import func Foundation.pow

public typealias FilterbankMagnitude = Float // typealias is public, Filterbank is not

final class Filterbank {
    private var bandpassFilters: [Filter]
    var magnitudes: [FilterbankMagnitude]

    static let bandwidthInOctaves = 0.012022 // TODO: tune this parameter

    init(noteRange: NoteRange, sampleRate: Double) {
        let frequencies = noteRange.fullRange.map { midiNum in midiNum.inHz }

        precondition(
            noteRange.fullRange.count % Filterbank.strideWidth == 0,
            "Filterbank now calculates multiple filters at once, please make the " +
            "note range divisible by Filterbank.stride (\(Filterbank.strideWidth))"
        )

        // Set up a constant Q filterbank, each filter with their own buffers:
        bandpassFilters = frequencies.map { freq -> Filter in
            return Filter(
                sampleRate: sampleRate,
                centreFrequency: freq,
                Q: calculateQFrom(bandWidthInOctaves: Filterbank.bandwidthInOctaves)
            )
        }

        magnitudes = [FilterbankMagnitude](repeating: 0, count: noteRange.fullRange.count)
    }

    private var x1: Float = 0
    private var x2: Float = 0

    static let strideWidth = 4


    func calculateMagnitudes (_ audioData: [Float]) -> [FilterbankMagnitude] {
        // We can't divide sum (a float4) by a scalar (below) so this is a workaround:
        let count = SIMD4<Float>(repeating: Float(audioData.count))

        for bi in stride(from: 0, through: bandpassFilters.count - Filterbank.strideWidth, by: Filterbank.strideWidth) {
            var filterA = bandpassFilters[bi + 0]
            var filterB = bandpassFilters[bi + 1]
            var filterC = bandpassFilters[bi + 2]
            var filterD = bandpassFilters[bi + 3]

            let b0s = SIMD4<Float>(x: filterA.b0, y: filterB.b0, z: filterC.b0, w: filterD.b0)
            let a1s = SIMD4<Float>(x: filterA.a1, y: filterB.a1, z: filterC.a1, w: filterD.a1)
            let a2s = SIMD4<Float>(x: filterA.a2, y: filterB.a2, z: filterC.a2, w: filterD.a2)

            var y1s = SIMD4<Float>(x: filterA.y1, y: filterB.y1, z: filterC.y1, w: filterD.y1)
            var y2s = SIMD4<Float>(x: filterA.y2, y: filterB.y2, z: filterC.y2, w: filterD.y2)
            var sum = SIMD4<Float>(x: 0, y: 0, z: 0, w: 0)

            var (x1, x2) = (self.x1, self.x2)

            for x in audioData {
                let inputDiff = x - x2
                // temporary variables because the compiler might not be able to typecheck the "let ys = ... " expression in a reasonable amount of time
                let temp1 = a1s * y1s
                let temp2 = a2s * y2s
                let ys = b0s * inputDiff - temp1 - temp2
                y2s = y1s
                y1s = ys

                let absYs = SIMD4<Float>(x: abs(ys.x), y: abs(ys.y), z: abs(ys.z), w: abs(ys.w))
                sum += absYs

                x2 = x1
                x1 = x
            }

            sum /= count // count is a float4, where each value == `input.count`
            magnitudes[bi + 0] = sum.x
            magnitudes[bi + 1] = sum.y
            magnitudes[bi + 2] = sum.z
            magnitudes[bi + 3] = sum.w

            (self.x1, self.x2) = (x1, x2)

            // Put y1 and y2 back into each filter array. Without this, the filters break in peak mode
            // and decay artifically quickly in RMS mode. It is correcter and doesn't affect CPU:
            filterA.y1 = y1s.x
            filterA.y2 = y2s.x
            filterB.y1 = y1s.y
            filterB.y2 = y2s.y
            filterC.y1 = y1s.z
            filterC.y2 = y2s.z
            filterD.y1 = y1s.w
            filterD.y2 = y2s.w

            bandpassFilters[bi + 0] = filterA
            bandpassFilters[bi + 1] = filterB
            bandpassFilters[bi + 2] = filterC
            bandpassFilters[bi + 3] = filterD
        }

        return magnitudes
    }
}

func calculateQFrom(bandWidthInOctaves N: Double) -> Double {
    let a = pow(2, N).squareRoot()
    let b = pow(2, N) - 1
    return a / b
}
