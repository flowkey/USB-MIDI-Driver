//
//  FilterBank.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 18.03.15.
//  Copyright (c) 2015 flowkey. All rights reserved.
//

#if os(Android)
import Glibc
#else
import simd
#endif

final class FilterBank {
    private var bandpassFilters: [Filter]
    let lowRange: CountableClosedRange<MIDINumber>
    let highRange: CountableClosedRange<MIDINumber>
    var magnitudes: [Float]

    init (lowRange: CountableClosedRange<MIDINumber>, highRange: CountableClosedRange<MIDINumber>, sampleRate: Double) {
        self.lowRange = lowRange
        self.highRange = highRange

        let noteRange = lowRange.first! ... highRange.last!
        let frequencies = noteRange.map { midiNum in midiNum.inHz }

        precondition(
            noteRange.count % FilterBank.strideWidth == 0,
            "FilterBank now calculates multiple filters at once, please make the " +
            "note range divisible by FilterBank.stride (\(FilterBank.strideWidth))"
        )

        // Set up a bunch of bandpass filters, each with their own buffers:
        bandpassFilters = frequencies.map { freq -> Filter in
            // It appears Q == 1 is one octave, and 120 is one semitone.
            // This would be less than one semitone:
            return Filter(sampleRate: sampleRate, centreFrequency: freq, Q: 180)
        }

        magnitudes = [Float](repeating: 0, count: noteRange.count)
    }

    private var x1: Float = 0
    private var x2: Float = 0

    static let strideWidth = 4

    func calculateMagnitudes (_ audioData: [Float]) {
        // We can't divide sum (a float4) by a scalar (below) so this is a workaround:
        let count = float4(Float(audioData.count))

        for bi in stride(from: 0, through: bandpassFilters.count - FilterBank.strideWidth, by: FilterBank.strideWidth) {
            var filterA = bandpassFilters[bi + 0]
            var filterB = bandpassFilters[bi + 1]
            var filterC = bandpassFilters[bi + 2]
            var filterD = bandpassFilters[bi + 3]

            let b0s = float4(x: filterA.b0, y: filterB.b0, z: filterC.b0, w: filterD.b0)
            let a1s = float4(x: filterA.a1, y: filterB.a1, z: filterC.a1, w: filterD.a1)
            let a2s = float4(x: filterA.a2, y: filterB.a2, z: filterC.a2, w: filterD.a2)

            var y1s = float4(x: filterA.y1, y: filterB.y1, z: filterC.y1, w: filterD.y1)
            var y2s = float4(x: filterA.y2, y: filterB.y2, z: filterC.y2, w: filterD.y2)
            var sum = float4(x: 0, y: 0, z: 0, w: 0)

            var (x1, x2) = (self.x1, self.x2)

            for x in audioData {
                let inputDiff = x - x2
                let ys = b0s * inputDiff - a1s * y1s - a2s * y2s
                y2s = y1s
                y1s = ys

                sum += abs(ys)

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
    }
}
