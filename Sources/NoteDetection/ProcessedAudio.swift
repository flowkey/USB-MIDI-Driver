//
//  ProcessedAudio.swift
//  NoteDetection
//
//  Created by Geordie Jay on 05.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

// To use these in the Testumgebung, import NoteDetection as @testable
public typealias ProcessedAudio = (
    audioData: [Float],
    chromaVector: ChromaVector,
    filterbankMagnitudes: [Float],
    onsetFeatureValue: Float,
    onsetThreshold: Float,
    onsetDetected: Bool
)
