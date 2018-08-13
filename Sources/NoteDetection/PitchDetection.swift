//
//  PitchDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//


typealias OnPitchDetectedCallback = (Timestamp) -> Void

class PitchDetection {
    init (lowNoteBoundary: MIDINumber) {
        self.lowNoteBoundary = lowNoteBoundary
        self.statusBuffer = [false, false, false]
    }

    // Let someone know when we play the event correctly
    var onPitchDetected: OnPitchDetectedCallback?

    fileprivate let lowNoteBoundary: MIDINumber
    fileprivate var statusBuffer: [Bool]    // Store the previous runs' status booleans
    let similarityThreshold: Float = 0.7    // If similarity is higher than this, event status is true
    var currentDetectionMode: DetectionMode = .highAndLow


    // MARK: Main processing functions:

    /// If we have a note to detect, compare the current ChromaVector's similarity with the one we expect
    /// Call "onNotesDetected" for the expected event if our statusBuffers are true
    func run(_ input: ChromaVector, _ timestampMs: Timestamp) {
        guard let expectedChroma = expectedChroma else { return }

        // remove oldest status
        statusBuffer.remove(at: 0)

        let similarity = input.similarity(to: expectedChroma)
        let requiredSimilarity = similarityThreshold - currentTolerance
        let currentBufferStatus = (similarity > requiredSimilarity)

        // insert new value
        statusBuffer.append(currentBufferStatus)

        if statusBufferIsAllTrue {
            onPitchDetected?(timestampMs)

            // Reset the status buffer to reduce the likelihood of repeated notes being detected immediately:
            statusBuffer = [Bool](repeating: false, count: statusBuffer.count)
        }
    }

    var statusBufferIsAllTrue: Bool {
        return statusBuffer.reduce(true, { $0 && $1 })
    }

    // MARK: Detection modes and expected events
    enum DetectionMode {
        case lowPitches, highPitches, highAndLow
    }

    private var expectedChroma: ChromaVector?
    private var currentTolerance: Float = 0

    func setExpectedEvent(_ event: DetectableNoteEvent?) {
        expectedChroma = ChromaVector(composeFrom: event?.notes) // result could be nil
        currentTolerance = event?.notes.calculateTolerance() ?? 0
        if let event = event { currentDetectionMode = detectionMode(from: event) }
    }

    fileprivate func detectionMode(from data: DetectableNoteEvent) -> DetectionMode {
        // Check how many low notes are expected in the event
        let lowNotesExpected: Int = data.notes.reduce(0) { (total, note) in
            return note < self.lowNoteBoundary ? (total + 1) : total
        }

        switch lowNotesExpected {
        case 0: return .highPitches                   // no low notes expected
        case data.notes.count: return .lowPitches     // no high notes expected
        default: return .highAndLow                   // check it all
        }
    }
}
