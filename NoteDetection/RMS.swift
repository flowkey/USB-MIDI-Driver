//
//  RMS.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 09.05.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation

class RMSOnsetDetection: OnsetDetection {
    var onsetFeatureBuffer = [OnsetDetection.FeatureValue](repeating: 0, count: 10)
    var threshold: Float = 0
    var onOnsetDetected: OnsetDetectedCallback?

    func compute(from inputData: [Float]) -> Float {
        return rootMeanSquare(inputData)
    }

    func computeThreshold(from data: [Float]) -> Float {
        let defaultThreshold: Float = 0.0001
        return max(median(data), defaultThreshold)
    }
}
