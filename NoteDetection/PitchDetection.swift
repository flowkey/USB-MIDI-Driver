//
//  PitchDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 27.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias OnNotesDetectedCallback = (_ timestamp: Double, NoteDetectionData) -> Void

public class PitchDetection {

    init (lowNoteBoundary: MIDINumber) {
        self.lowNoteBoundary = lowNoteBoundary
        self.statusBuffer = [false, false, false]
    }

    // Let someone know when we play the event correctly
    public var onNotesDetected: OnNotesDetectedCallback?

    fileprivate let lowNoteBoundary: MIDINumber
    fileprivate var statusBuffer: [Bool]       // Store the previous runs' status booleans
    let similarityThreshold: Float = 0.7   // If similarity is higher than this, event status is true
    var currentDetectionMode: DetectionMode = .highAndLow


    // MARK: Main processing functions:

    func run(_ input: ChromaVector) {

        // If we have an event, compare its ChromaVector to the one we just received here
        // Call "onNotesDetected" for the expected event if our statusBuffers are true

        if let noteDetectionData = self.expectedNoteEvent {

            // remove oldest status
            statusBuffer.remove(at: 0)

            let similarity = input.similarity(to: noteDetectionData.expectedChroma)
            let requiredSimilarity = similarityThreshold - noteDetectionData.tolerance
            let currentBufferStatus = (similarity > requiredSimilarity)

            // insert new value
            statusBuffer.append(currentBufferStatus)

            if statusBufferIsAllTrue {
                performOnMainThread { self.onNotesDetected?(getTimeInMillisecondsSince1970(), noteDetectionData) }

                // Reset the status buffer to reduce the likelihood of repeated notes being detected immediately:
                statusBuffer = [Bool](repeating: false, count: statusBuffer.count)
            }
        }

    }

    var statusBufferIsAllTrue: Bool {
        // http://ijoshsmith.com/2014/06/25/understanding-swifts-reduce-method/
        return statusBuffer.reduce(true) { $0 && $1 }
    }

    // MARK: Detection modes and expected events

    enum DetectionMode: CustomDebugStringConvertible {
        case lowPitches,  // for the low bass notes (filterbank)
        highPitches, // for higher notes       (fft spectrum)
        highAndLow   // for events with low and high notes

        var debugDescription: String {
            switch self {
            case .lowPitches: return "Detect low notes only"
            case .highPitches: return "Detect high notes only"
            case .highAndLow: return "Detect low _and_ high notes"
            }
        }
    }

    public var expectedNoteEvent: NoteDetectionData? {
        didSet {if let event = expectedNoteEvent {
            currentDetectionMode = detectionModeForEvent(event)
        }}
    }

    fileprivate func detectionModeForEvent(_ event: NoteDetectionData) -> DetectionMode {
        // Check how many low notes are expected in the event
        let lowNotesExpected: Int = event.notes.reduce(0) { (total, note) in
            return note < self.lowNoteBoundary ? (total + 1) : total
        }

        switch lowNotesExpected {
        case 0: return .highPitches                   // no low notes expected
        case event.notes.count: return .lowPitches    // no high notes exptected
        default: return .highAndLow                   // check it all
        }
    }
}
