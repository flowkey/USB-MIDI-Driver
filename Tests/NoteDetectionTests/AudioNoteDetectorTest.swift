import XCTest
@testable import NoteDetection

private let sampleRate = 44100.0

class AudioNoteDetectorTests: XCTestCase {
    var audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)

    override func setUp() {
        super.setUp()
        audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)
    }

    func testTimestampsAreCloseEnough() {
        let expectation = XCTestExpectation(description: "onNoteEventDetected was called")

        audioNoteDetector.onNoteEventDetected = { timestamp in
            expectation.fulfill()
        }

        let now: Timestamp = .now
        let then: Timestamp = now + AudioNoteDetector.maxNoteToOnsetTimeDelta / 2
        audioNoteDetector.onOnsetDetected(timestamp: now)
        audioNoteDetector.onPitchDetected(timestamp: then)

        wait(for: [expectation], timeout: 0.1)
    }

    func testTimestampsAreNotCloseEnough() {
        var noteWasDetected = false
        audioNoteDetector.onNoteEventDetected = { timestamp in
            noteWasDetected = true
        }

        audioNoteDetector.onOnsetDetected(timestamp: .now)
        audioNoteDetector.onPitchDetected(timestamp: .now + AudioNoteDetector.maxNoteToOnsetTimeDelta + 1)

        XCTAssert(noteWasDetected == false)
    }
}
