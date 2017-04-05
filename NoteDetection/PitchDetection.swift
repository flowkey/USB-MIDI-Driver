//
//  PitchDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//


typealias OnPitchDetectedCallback = (Timestamp) -> Void

class PitchDetection {

    init (lowNoteBoundary: MIDINumber, onPitchDetected: @escaping OnPitchDetectedCallback) {
        self.onPitchDetected = onPitchDetected
        self.lowNoteBoundary = lowNoteBoundary
        self.statusBuffer = [false, false, false]
    }

    // Let someone know when we play the event correctly
    let onPitchDetected: OnPitchDetectedCallback

    fileprivate let lowNoteBoundary: MIDINumber
    fileprivate var statusBuffer: [Bool]       // Store the previous runs' status booleans
    let similarityThreshold: Float = 0.7   // If similarity is higher than this, event status is true
    var currentDetectionMode: DetectionMode = .highAndLow


    // MARK: Main processing functions:

    func run(_ input: ChromaVector) {

        // If we have an event, compare its ChromaVector to the one we just received here
        // Call "onNotesDetected" for the expected event if our statusBuffers are true

        if let pitchDetectionData = self.expectedPitchDetectionData {

            // remove oldest status
            statusBuffer.remove(at: 0)

            let similarity = input.similarity(to: pitchDetectionData.expectedChroma)
            let requiredSimilarity = similarityThreshold - pitchDetectionData.tolerance
            let currentBufferStatus = (similarity > requiredSimilarity)

            // insert new value
            statusBuffer.append(currentBufferStatus)

            if statusBufferIsAllTrue {
                performOnMainThread { self.onPitchDetected(.now) }

                // Reset the status buffer to reduce the likelihood of repeated notes being detected immediately:
                statusBuffer = [Bool](repeating: false, count: statusBuffer.count)
            }
        }

    }

    var statusBufferIsAllTrue: Bool {
        return statusBuffer.reduce(true) { $0 && $1 }
    }


    // MARK: Detection modes and expected events
    enum DetectionMode {
        case lowPitches, highPitches, highAndLow
    }

    var expectedPitchDetectionData: PitchDetectionData? {
        didSet {if let pitchDetectionData = expectedPitchDetectionData {
            currentDetectionMode = getDetectionMode(from: pitchDetectionData)
        }}
    }

    fileprivate func getDetectionMode(from data: PitchDetectionData) -> DetectionMode {
        // Check how many low notes are expected in the event
        let lowNotesExpected: Int = data.notes.reduce(0) { (total, note) in
            return note < self.lowNoteBoundary ? (total + 1) : total
        }

        switch lowNotesExpected {
        case 0: return .highPitches                   // no low notes expected
        case data.notes.count: return .lowPitches    // no high notes expected
        default: return .highAndLow                   // check it all
        }
    }
}
