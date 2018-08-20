//
//  PitchDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//


typealias OnPitchDetectedCallback = (Timestamp) -> Void

class PitchDetection {
    struct DetectionResult {
        let timestamp: Timestamp
        let expectedChroma: ChromaVector
        let detectedChroma: ChromaVector
        let similarity: Float
        let chromaTolerance: Float
        let pitchWasDetected: Bool
    }

    init(noteRange: NoteRange) {
        self.noteRange = noteRange
        self.statusBuffer = [false, false, false]
    }

    // Let someone know when we play the event correctly
    var onPitchDetected: OnPitchDetectedCallback?

    private let noteRange: NoteRange
    private var statusBuffer: [Bool]    // Store the previous runs' status booleans
    private let similarityThreshold: Float = 0.7    // If similarity is higher than this, event status is true
    private var currentDetectionMode: DetectionMode = .highAndLow


    // MARK: Main processing functions:

    /// If we have a note to detect, compare the current ChromaVector's similarity with the one we expect
    /// Call "onNotesDetected" for the expected event if our statusBuffers are true
    func run(on filterbankMagnitudes: [FilterBank.Magnitude], at timestampMs: Timestamp) -> DetectionResult? {
        guard let expectedChroma = expectedChroma else { return nil }

        let detectedChroma = chroma(from: filterbankMagnitudes)

        // remove oldest status
        statusBuffer.remove(at: 0)

        let similarity = detectedChroma.similarity(to: expectedChroma)
        let requiredSimilarity = similarityThreshold - currentTolerance
        let currentBufferStatus = (similarity > requiredSimilarity)

        // insert new value
        statusBuffer.append(currentBufferStatus)

        let pitchWasDetected = statusBufferIsAllTrue
        if pitchWasDetected {
            onPitchDetected?(timestampMs)

            // Reset the status buffer to reduce the likelihood of repeated notes being detected immediately:
            statusBuffer = [Bool](repeating: false, count: statusBuffer.count)
        }

        return DetectionResult(timestamp: timestampMs, expectedChroma: expectedChroma, detectedChroma: detectedChroma, similarity: similarity, chromaTolerance: currentTolerance, pitchWasDetected: pitchWasDetected)
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
            return note < self.noteRange.lowNoteBoundary ? (total + 1) : total
        }

        switch lowNotesExpected {
        case 0: return .highPitches                   // no low notes expected
        case data.notes.count: return .lowPitches     // no high notes expected
        default: return .highAndLow                   // check it all
        }
    }

    func chroma(from magnitudes: [FilterBank.Magnitude]) -> ChromaVector {
        // These only get calculated if you actually access them:
        /// Extracted from filterbank magnitudes within __LOW__ range
        var lowChroma: ChromaVector {
            return ChromaVector(from: magnitudes, startingAt: noteRange.first, range: noteRange.lowRange)
        }

        /// Extracted from filterbank magnitudes within __HIGH__ range
        var highChroma: ChromaVector {
            return ChromaVector(from: magnitudes, startingAt: noteRange.first, range: noteRange.highRange)
        }

        switch currentDetectionMode {
        case .lowPitches:  return lowChroma
        case .highPitches: return highChroma
        case .highAndLow:  return lowChroma + highChroma
        }
    }
}
