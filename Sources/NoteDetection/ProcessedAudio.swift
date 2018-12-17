//
//  ProcessedAudio.swift
//  NoteDetection
//
//  Created by Geordie Jay on 05.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

// To use these in the Testumgebung, import NoteDetection as @testable
public struct ProcessedAudio {
    public let audioData: [Float]
    public let chromaVector: [Float]
    public let filterbankMagnitudes: [Float]
    public let onsetFeatureValue: Float
    public let onsetThreshold: Float
    public let onsetDetected: Bool
}
