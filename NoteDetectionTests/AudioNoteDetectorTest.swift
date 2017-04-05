import XCTest
@testable import NoteDetection


let arbitrarySampleRate: Double = 1000

func afterTimeout(ms timeout: Double, callback: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout / 1000, execute: callback)
}

class AudioNoteDetectorTests: XCTestCase {

    var audioNoteDetector = AudioNoteDetector(sampleRate: arbitrarySampleRate)

    override func setUp() {
        super.setUp()
        audioNoteDetector = AudioNoteDetector(sampleRate: arbitrarySampleRate)
    }

    override func tearDown() {
        super.tearDown()
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
            XCTAssert(true)
        }


        afterTimeout(ms: 0, callback: { self.audioNoteDetector.onOnsetDetected(timestamp: .now) })
        afterTimeout(ms: 300, callback: { self.audioNoteDetector.onPitchDetected(timestamp: .now) })

        afterTimeout(ms: 500, callback: { expectation.fulfill() })

        self.waitForExpectations(timeout: 0.5) { error in
            if let error = error {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
