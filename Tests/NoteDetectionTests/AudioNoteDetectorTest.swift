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
        
        audioNoteDetector.expectedNoteEvent = NoteEvent(notes: [69])
        
        audioNoteDetector.delegate = noteDetectorDelegate

        let now = 0.0
        let then = now + AudioNoteDetector.maxNoteToOnsetTimeDelta / 2
        audioNoteDetector.onOnsetDetected(timestamp: now)
        audioNoteDetector.onPitchDetected(timestamp: then)

        wait(for: [notesDetectedExpectation], timeout: 0.1)
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
}
