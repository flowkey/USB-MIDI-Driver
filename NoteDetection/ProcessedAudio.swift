//
//  ProcessedAudio.swift
//  NoteDetection
//
//  Created by Geordie Jay on 05.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//


// These types are deliberately NOT public, because we don't want them accessible outside of flowkey
// To use them in the Testumgebung, import NoteDetection as @testable
typealias OnAudioProcessedCallback = (ProcessedAudio) -> Void

typealias ProcessedAudio = (
    audioData: [Float],
    chromaVector: ChromaVector,
    filterbankMagnitudes: [Float],
    onsetFeatureValue: Float,
    onsetThreshold: Float,
    onsetDetected: Bool
)
