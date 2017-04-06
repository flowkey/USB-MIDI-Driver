import XCTest
@testable import NoteDetection

func afterTimeout(ms timeout: Double, callback: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout / 1000, execute: callback)
}

private let sampleRate = 44100.0

class AudioNoteDetectorTests: XCTestCase {
    var audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)

    override func setUp() {
        super.setUp()
        audioNoteDetector = AudioNoteDetector(sampleRate: sampleRate)
    }

    func testTimestampsAreCloseEnough() {

        let expectation = self.expectation(description: "listener executed because timestamps are close enough")

        audioNoteDetector.onNoteEventDetected = { timestamp in
            expectation.fulfill()
        }

        afterTimeout(ms: 0, callback: { self.audioNoteDetector.onOnsetDetected(timestamp: .now) })
        afterTimeout(ms: 100, callback: { self.audioNoteDetector.onPitchDetected(timestamp: .now) })


        self.waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testTimestampsAreNotCloseEnough() {
        let expectation = self.expectation(description: "listener not executed because timestamps are NOT close enough")

        audioNoteDetector.onNoteEventDetected = { timestamp in
            XCTFail("We shouldn't have detected a note because the timestamps happen close to one another in time")
        }

        let firstEventTime = 0.0
        let secondEventTime = AudioNoteDetector.maxTimestampDiff + 1

        afterTimeout(ms: firstEventTime, callback: { self.audioNoteDetector.onOnsetDetected(timestamp: .now) })
        afterTimeout(ms: secondEventTime, callback: { self.audioNoteDetector.onPitchDetected(timestamp: .now) })
        afterTimeout(ms: secondEventTime * 2, callback: { expectation.fulfill() })

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
