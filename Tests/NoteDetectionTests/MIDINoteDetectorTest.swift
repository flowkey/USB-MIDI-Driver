import XCTest
@testable import NoteDetection

class MIDINoteDetectorTests: XCTestCase {
    var midiNoteDetector = MIDINoteDetector()
    var noteDetectorDelegate: NoteDetectorTestDelegate? // keep a ref to delegate
    let noteEvents = anotherDayInParadiseNoteEvents

    override func setUp() {
        super.setUp()
        midiNoteDetector = MIDINoteDetector()
        noteDetectorDelegate = nil
    }

    func testIfFollowsOnRandomEvent() {
        // testing with async expectation because MIDINoteDetector uses DispatchQueue.main.async
        let notesDetectedExpectation = expectation(description: "notes were detected")
        noteDetectorDelegate = NoteDetectorTestDelegate(callback: {
            notesDetectedExpectation.fulfill()
        })
        midiNoteDetector.delegate = noteDetectorDelegate

        let randomEventIndex = getRandomEventIndexFrom(noteEvents: noteEvents)
        midiNoteDetector.expectedNoteEvent = noteEvents[randomEventIndex]
        
        guard let noteEvent = midiNoteDetector.expectedNoteEvent else {
            XCTFail()
            return
        }

        let arbitraryTimestamp: MIDITime = 123
        for note in noteEvent.notes {
            let message = MIDIMessage.noteOn(key: UInt8(note), velocity: 10)
            midiNoteDetector.process(midiMessage: message, from: nil, at: arbitraryTimestamp)
        }

        wait(for: [notesDetectedExpectation], timeout: 0.1)
    }

    func testIfMIDIArrayIsEmptyAfterNoteOff() {
        let arbitraryNoteOnTime: MIDITime = 1000
        let arbitraryNoteOffTime: MIDITime = 2000

        // add some keys
        midiNoteDetector.process(
            midiMessage: .noteOn(key: 69, velocity: 10),
            from: nil,
            at: arbitraryNoteOnTime
        )
        midiNoteDetector.process(
            midiMessage: .noteOn(key: 69 + 12, velocity: 10),
            from: nil,
            at: arbitraryNoteOnTime
        )

        // remove them again
        midiNoteDetector.process(
            midiMessage: .noteOff(key: 69),
            from: nil,
            at: arbitraryNoteOffTime
        )
        midiNoteDetector.process(
            midiMessage: .noteOff(key: 69 + 12),
            from: nil,
            at: arbitraryNoteOffTime
        )

        XCTAssertTrue(midiNoteDetector.currentMIDIKeys.isEmpty)
    }

    func testIfItFollowsWhenSetContainsNotExpectedKeys() {
        let arbitraryTimestamp: MIDITime = 1000
        let notesDetectedExpectation = expectation(description: "notes were detected")
        
        noteDetectorDelegate = NoteDetectorTestDelegate(callback: {
            notesDetectedExpectation.fulfill()
        })
        
        midiNoteDetector.delegate = noteDetectorDelegate
        
        let randomEventIndex = getRandomEventIndexFrom(noteEvents: noteEvents)
        midiNoteDetector.expectedNoteEvent = noteEvents[randomEventIndex]

        // add not expected key
        midiNoteDetector.process(
            midiMessage: .noteOn(key: 0, velocity: 10),
            from: nil,
            at: arbitraryTimestamp
        )

        guard let noteEvent = midiNoteDetector.expectedNoteEvent else {
            XCTFail()
            return
        }

        // add expected keys
        for note in noteEvent.notes {
            midiNoteDetector.process(midiMessage: .noteOn(key: UInt8(note), velocity: 10), from: nil, at: 0)
        }

        wait(for: [notesDetectedExpectation], timeout: 0.1)
    }

}


private func getRandomEventIndexFrom(noteEvents: [NoteEvent]) -> Int {
    return randomIntFromRange(lower: 0, upper: noteEvents.count - 1)
}

private func randomIntFromRange (lower: Int, upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
