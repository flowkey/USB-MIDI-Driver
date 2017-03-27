//
//  ProcessedAudio.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public struct ProcessedAudio {
    public let audioData: [Float]
    public let chromaVector: ChromaVector
    public let filterBandAmplitudes: [Float]
    public let onsetFeatureValue: Float
    public let onsetThreshold: Float
    public let onsetDetected: Bool

    // We need a public initializer for the Testumgebung, add default data while we're at it..
    public init(
        audioData: [Float] = [],
        chromaVector: ChromaVector = ChromaVector(),
        filterBandAmplitudes: [Float] = [],
        onsetFeatureValue: Float = 0,
        onsetThreshold: Float = 0,
        onsetDetected: Bool = false
    ) {
        self.audioData = audioData
        self.chromaVector = chromaVector
        self.filterBandAmplitudes = filterBandAmplitudes
        self.onsetFeatureValue = onsetFeatureValue
        self.onsetThreshold = onsetThreshold
        self.onsetDetected = onsetDetected
    }
}
