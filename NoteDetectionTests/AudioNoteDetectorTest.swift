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
            XCTFail("We shouldn't have detected a note because the timestamps are note close enough")
        }

        let firstEventTime = 0.0
        let secondEventTime = AudioNoteDetector.maxTimestampDiff + 1 // duration to second event longer than maxTimeStampDiff

        afterTimeout(ms: firstEventTime, callback: { self.audioNoteDetector.onOnsetDetected(timestamp: .now) })
        afterTimeout(ms: secondEventTime, callback: { self.audioNoteDetector.onPitchDetected(timestamp: .now) })
        afterTimeout(ms: secondEventTime * 2, callback: { expectation.fulfill() })

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }

    func testAcceptingOnsets() {

        let isNotAcceptingOnsets = self.expectation(description: "currently _not_ accepting onsets")
        let isAcceptingOnsets = self.expectation(description: "currently accepting onsets")

        let event1 = anotherDayInParadiseNoteEvents[0]
        let event2 = anotherDayInParadiseNoteEvents[0]

        XCTAssertEqual(event1.timeToNext, NoteEvent.timeToNextMock)
        XCTAssertEqual(event2.timeToNext, NoteEvent.timeToNextMock)

        audioNoteDetector.onNoteEventDetected = { timestamp in
            self.audioNoteDetector.expectedNoteEvent = event2
        }


        // detect note event with pitch and onset
        audioNoteDetector.expectedNoteEvent = event1
        self.audioNoteDetector.onOnsetDetected(timestamp: .now)
        self.audioNoteDetector.onPitchDetected(timestamp: .now)

        // detector should not accept onsets right after note event detected
        let timeWithinBlockingPeriod = event1.timeToNext * AudioNoteDetector.timeToNextToleranceFactor - 10
        afterTimeout(ms: timeWithinBlockingPeriod, callback: {
            if self.audioNoteDetector.currentlyAcceptingOnsets() == false {
                isNotAcceptingOnsets.fulfill()
            }
        })

        // after onset blocking period, detector should accepts onsets again
        let timeAfterBlockingPeriod = event1.timeToNext * AudioNoteDetector.timeToNextToleranceFactor + 10
        afterTimeout(ms: timeAfterBlockingPeriod, callback: {
            if self.audioNoteDetector.currentlyAcceptingOnsets() == true {
                isAcceptingOnsets.fulfill()
            }
        })

        waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
