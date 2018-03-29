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
        var noteWasDetected = false
        audioNoteDetector.onNoteEventDetected = { timestamp in
            noteWasDetected = true
        }

        audioNoteDetector.onOnsetDetected(timestamp: .now)
        audioNoteDetector.onPitchDetected(timestamp: .now + AudioNoteDetector.maxNoteToOnsetTimeDelta / 2)

        XCTAssert(noteWasDetected)
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
