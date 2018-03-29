//
//  Filter.swift
//  NativePitchDetection
//
//  Created by Geordie Jay on 15.12.15.
//  Copyright © 2015 Geordie Jay. All rights reserved.
//

// swiftlint:disable variable_name

import Foundation

struct Filter {
    let b0: Float
    let a1: Float
    let a2: Float
    var y1 = Float(0)
    var y2 = Float(0)

    init(sampleRate: Double, centreFrequency: Double, Q: Double) {
        guard centreFrequency > 0 && Q > 0 else {
            fatalError("filter frequency and Q must be > 0")
        }

        let omega = 2 * .pi * centreFrequency / sampleRate
        let omegaS = sin(omega)
        let omegaC = cos(omega)
        let alpha = omegaS / (2*Q)

        let a0 = 1 + alpha
        let a1 = (-2 * omegaC)  / a0
        let a2 = (1 - alpha)    / a0
        let b0 = alpha          / a0
        //    let b1 = Double(0)      / a0 -- not used
        //    let b2 = -alpha         / a0 --

        if abs(a1) < (1 + a2) {
        } else {
            print("Warning: a1 is unstable for sampleRate: \(sampleRate)", centreFrequency, Q)
        }

        if abs(a2) < 1 {
        } else {
            print("Warning: a2 is unstable for sampleRate: \(sampleRate)", centreFrequency, Q)
        }

        self.b0 = Float(b0)
        self.a1 = Float(a1)
        self.a2 = Float(a2)
    }

#if !os(iOS)
    /// only used for Android, where we have no SIMD instructions yet
    /// inputDiff is the value of (inputFrame[n] - inputFrame[n-2])
    mutating func calculateOutputFrame(_ inputDiff: Float) -> Float {
        let y = b0 * inputDiff - a1 * y1 - a2 * y2
        y2 = y1
        y1 = y

        return y
    }
#endif

}
