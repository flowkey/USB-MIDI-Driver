import XCTest
@testable import NoteDetection

private let sampleRate = 44100.0

class AudioNoteDetectorTests: XCTestCase {
    var audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)
    var noteDetectorDelegate: NoteDetectorTestDelegate? // keep a ref to delegate
    
    override func setUp() {
        super.setUp()
        audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)
    }

    func testTimestampsAreCloseEnough() {
        let notesDetectedExpectation = XCTestExpectation(description: "onNoteEventDetected was called")
        
        noteDetectorDelegate = NoteDetectorTestDelegate(callback: {
            notesDetectedExpectation.fulfill()
        })
        
        audioNoteDetector.expectedNoteEvent = NoteEvent(notes: [69], id: 0)
        
        audioNoteDetector.delegate = noteDetectorDelegate

        let now = 0.0
        let then = now + AudioNoteDetector.maxNoteToOnsetTimeDelta / 2
        audioNoteDetector.onOnsetDetected(timestamp: now)
        audioNoteDetector.onPitchDetected(timestamp: then)

        wait(for: [notesDetectedExpectation], timeout: 0.1)
    }

    func testGetNoteEventDetectedTimeWhenOnsetIsRequired() {
        let onsetTimestamp = AudioTime(10)
        let noteTimestamp = AudioTime(20)
        let noteEventDetectedTimestamp = getNoteEventDetectedTimeFrom(
            noteTimestamp: noteTimestamp,
            onsetTimestamp: onsetTimestamp,
            onsetIsRequired: true
        )

        XCTAssertEqual(noteEventDetectedTimestamp, noteTimestamp)
    }

    func testGetNoteEventDetectedTimeWhenOnsetIsNotRequired() {
        let onsetTimestamp = AudioTime(10)
        let noteTimestamp = AudioTime(20)
        let noteEventDetectedTimestamp = getNoteEventDetectedTimeFrom(
            noteTimestamp: noteTimestamp,
            onsetTimestamp: onsetTimestamp,
            onsetIsRequired: false
        )

        XCTAssertEqual(noteEventDetectedTimestamp, noteTimestamp)
    }

    func testGetNoteEventDetectedTimeWhenOnsetIsRequiredAndNoteTimestampIsNil() {
        let onsetTimestamp = AudioTime(10)
        let noteTimestamp: AudioTime? = nil
        let noteEventDetectedTimestamp = getNoteEventDetectedTimeFrom(
            noteTimestamp: noteTimestamp,
            onsetTimestamp: onsetTimestamp,
            onsetIsRequired: true
        )

        XCTAssertNil(noteEventDetectedTimestamp)
    }

    func testExpectedChromaVectorsInit() {
        let noteEvent = NoteEvent(notes: [69], id: 0)
        let pitchDetection = PitchDetection(noteRange: .standard)

        // both vectors should be nil right after initing
        XCTAssertNil(pitchDetection.expectedChroma)
        XCTAssertNil(pitchDetection.previousExpectedChroma)

        // set expected event once
        pitchDetection.expectedNoteEvent = noteEvent

        // since we only set the expected event once, the previous expected chroma vector should still be nil
        XCTAssertNil(pitchDetection.previousExpectedChroma)
        XCTAssertEqual(pitchDetection.expectedChroma, ChromaVector(composeFrom: noteEvent.notes))
    }

    func testExpectedChromaVectorsAfterSettingDifferentEvents() {
        let noteEvent1 = NoteEvent(notes: [69], id: 0)
        let noteEvent2 = NoteEvent(notes: [70], id: 1)
        let pitchDetection = PitchDetection(noteRange: .standard)

        pitchDetection.expectedNoteEvent = noteEvent1
        pitchDetection.expectedNoteEvent = noteEvent2

        XCTAssertEqual(
            pitchDetection.previousExpectedChroma,
            ChromaVector(composeFrom: noteEvent1.notes)
        )

        XCTAssertEqual(
            pitchDetection.expectedChroma,
            ChromaVector(composeFrom: noteEvent2.notes)
        )
    }

    func testIfPreviousExpectedChromaVectorUpdatesAfterSettingSameEventTwice() {
        let noteEvent = NoteEvent(notes: [69], id: 0)
        let pitchDetection = PitchDetection(noteRange: .standard)

        pitchDetection.expectedNoteEvent = noteEvent
        pitchDetection.expectedNoteEvent = noteEvent

        // when we set the same event (same ID) twice in a row,
        // the previous expected vector should NOT update
        XCTAssertNotEqual(pitchDetection.previousExpectedChroma, pitchDetection.expectedChroma)
    }

    func testTimestampsAreNotCloseEnough() {
        var noteWasDetected = false
        audioNoteDetector.delegate = NoteDetectorTestDelegate(callback: {
            noteWasDetected = true
        })

        let now = 0.0
        let then = now + AudioNoteDetector.maxNoteToOnsetTimeDelta + 1
        audioNoteDetector.onOnsetDetected(timestamp: now)
        audioNoteDetector.onPitchDetected(timestamp: then)

        XCTAssert(noteWasDetected == false)
    }
    
    func testIfNoteDetectionIsIgnoring() {
        let audioNoteDetector = AudioNoteDetector(sampleRate: 44100)
        
        audioNoteDetector.process(audio: [], at: 0)
        audioNoteDetector.ignoreFor(ms: 100)

        let isIgnoring = audioNoteDetector.isIgnoring(at: 50)
        XCTAssertEqual(isIgnoring, true)
    }
    
    func testIfNoteDetectionIsIgnoringEnded() {
        let audioNoteDetector = AudioNoteDetector(sampleRate: 44100)
        
        audioNoteDetector.process(audio: [], at: 0)
        audioNoteDetector.ignoreFor(ms: 100)
        
        let isIgnoring = audioNoteDetector.isIgnoring(at: 150)
        XCTAssertEqual(isIgnoring, false)
    }

    func testIfExpectedChromaIsNullAfterSettingExpectedEventToNull() {
        let pitchDetection = PitchDetection(noteRange: .standard)
        XCTAssertNil(pitchDetection.expectedChroma)

        pitchDetection.expectedNoteEvent = NoteEvent(notes: [69], id: 0)
        XCTAssertNotNil(pitchDetection.expectedChroma)

        pitchDetection.expectedNoteEvent = nil
        XCTAssertNil(pitchDetection.expectedChroma)
    }
}
