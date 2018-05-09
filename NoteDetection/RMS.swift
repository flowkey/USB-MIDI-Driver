//
//  RMS.swift
//  NoteDetectionIOS
//
//  Created by flowing erik on 09.05.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

import Foundation

class RMS {
    private let defaultThreshold: Float = 0.0001
    let defaultFeatureBufferSize: Int = 10

    func compute(from inputData: [Float]) -> Float {
        return rootMeanSquare(inputData)
    }

    func computeThreshold(from data: [Float]) -> Float {
       return max(median(data), self.defaultThreshold)
    }
}

