//
//  PitchDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//


typealias OnPitchDetectedCallback = (AudioTime) -> Void
public struct PitchDetectionResult {
    let timestamp: AudioTime
    let expectedChroma: ChromaVector
    let detectedChroma: ChromaVector
    let similarity: Float
    let chromaTolerance: Float
    let pitchWasDetected: Bool
}

class PitchDetection {
    init(noteRange: NoteRange) {
        self.noteRange = noteRange
        self.statusBuffer = [false, false, false]
    }

    // Let someone know when we play the event correctly
    var onPitchDetected: OnPitchDetectedCallback?

    let noteRange: NoteRange
    private var statusBuffer: [Bool]    // Store the previous runs' status booleans
    private let similarityThreshold: Float = 0.7    // If similarity is higher than this, event status is true
    private var currentDetectionMode: DetectionMode = .highAndLow


    // MARK: Main processing functions:

    /// If we have a note to detect, compare the current ChromaVector's similarity with the one we expect
    /// Call "onNotesDetected" for the expected event if our statusBuffers are true
    func run(on filterbankMagnitudes: [FilterbankMagnitude], at timestampMs: AudioTime) -> PitchDetectionResult? {
        guard let expectedChroma = expectedChroma else { 
            return nil
        }

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

        return PitchDetectionResult(timestamp: timestampMs, expectedChroma: expectedChroma, detectedChroma: detectedChroma, similarity: similarity, chromaTolerance: currentTolerance, pitchWasDetected: pitchWasDetected)
    }

    var statusBufferIsAllTrue: Bool {
        return statusBuffer.reduce(true, { $0 && $1 })
    }

    // MARK: Detection modes and expected events
    enum DetectionMode {
        case lowPitches, highPitches, highAndLow
    }

    private(set) var previousExpectedChroma: ChromaVector?
    private(set) var expectedChroma: ChromaVector? {
        didSet { previousExpectedChroma = oldValue }
    }

    private var currentTolerance: Float = 0

    var expectedNoteEvent: DetectableNoteEvent? {
        didSet {
            if
                oldValue?.id == expectedNoteEvent?.id,
                oldValue?.notes == expectedNoteEvent?.notes
            {
              return
            }
            
            if let notes = expectedNoteEvent?.notes {
                expectedChroma = ChromaVector(composeFrom: notes)
                currentTolerance = notes.calculateTolerance()
                currentDetectionMode = detectionMode(from: notes)
            } else {
                expectedChroma = nil
            }
        }
    }

    fileprivate func detectionMode(from notes: Set<MIDINumber> ) -> DetectionMode {
        // Check how many low notes are expected in the event
        let lowNotesExpected: Int = notes.reduce(0) { (total, note) in
            return note < self.noteRange.lowNoteBoundary ? (total + 1) : total
        }

        switch lowNotesExpected {
        case 0: return .highPitches             // no low notes expected
        case notes.count: return .lowPitches    // no high notes expected
        default: return .highAndLow             // check it all
        }
    }

    func chroma(from magnitudes: [FilterbankMagnitude]) -> ChromaVector {
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
