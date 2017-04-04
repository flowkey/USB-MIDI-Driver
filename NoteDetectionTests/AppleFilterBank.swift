//
//  AppleFilterBank.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 10.03.17.
//  Copyright © 2017 Geordie Jay. All rights reserved.
//

// swiftlint:disable variable_name

import Accelerate
import NoteDetection


class AppleFilter {
    init(sampleRate: Double, centreFrequency: Double, Q: Double) {
        guard centreFrequency > 0 && Q > 0 else {
            fatalError("filter frequency and Q must be > 0")
        }

        let omega = 2 * Double.pi * centreFrequency / sampleRate
        let omegaS = sin(omega)
        let omegaC = cos(omega)
        let alpha = omegaS / (2*Q)

        let a0 = 1 + alpha
        let a1 = (-2 * omegaC)  / a0
        let a2 = (1 - alpha)    / a0
        let b0 = alpha          / a0
        let b1 = 0.0            / a0
        let b2 = -alpha         / a0

        if abs(a1) < (1 + a2) {
        } else {
            print("|a1| < 1 + a2")
            print("Warning: a1 is unstable\n")
        }

        if abs(a2) < 1 {
        } else {
            print("|a2| < 1")
            print("Warning: a2 is unstable\n")
        }

        self.coefficients = [Float(b0), Float(b1), Float(b2), Float(a1), Float(a2)]
    }

    let coefficients: [Float]

    var initedBufferLength = 0
    var outputBuffer: UnsafeMutablePointer<Float>!

    var y1 = Float(0)
    var y2 = Float(0)

    func filter(_ inputArray: [Float]) -> Float {
        let count = inputArray.count

        if initedBufferLength != count + 2 {
            outputBuffer?.deallocate(capacity: initedBufferLength)
            outputBuffer = UnsafeMutablePointer<Float>.allocate(capacity: count + 2)
            initedBufferLength = count + 2
        }

        var meanMagnitude = Float(0)
        outputBuffer[0] = y2
        outputBuffer[1] = y1

        vDSP_deq22(inputArray, 1, coefficients, outputBuffer, 1, vDSP_Length(count))
        vDSP_meamgv(outputBuffer, 1, &meanMagnitude, vDSP_Length(count))

        y2 = outputBuffer[count - 2]
        y1 = outputBuffer[count - 1]

        return meanMagnitude
    }

    deinit {
        outputBuffer?.deallocate(capacity: initedBufferLength)
    }
}


class AppleFilterBank {
    let filters: [AppleFilter]
    var magnitudes: [Float]

    init(noteRange: CountableClosedRange<MIDINumber>, sampleRate: Double) {
        filters = noteRange.map { AppleFilter(sampleRate: sampleRate, centreFrequency: $0.inHz, Q: 180) }
        magnitudes = [Float](repeating: 0, count: noteRange.count)
    }

    var x1 = Float(0)
    var x2 = Float(0)

    func calculateMagnitudes(_ input: [Float]) {
        let paddedInput = [x2, x1] + input
        filters.enumerated().forEach { i, freq in magnitudes[i] = freq.filter(paddedInput) }
        x2 = input[input.count - 2]
        x1 = input[input.count - 1]
    }
}
