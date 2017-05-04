import XCTest
@testable import NoteDetection

class MIDIDInputMock: MIDIInput {
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {}
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?) {}
}

class MIDINoteDetectorTests: XCTestCase {

    var midiNoteDetector = MIDINoteDetector(input: MIDIDInputMock())
    let noteEvents = anotherDayInParadiseNoteEvents

    override func setUp() {
        super.setUp()
        midiNoteDetector = MIDINoteDetector(input: MIDIDInputMock())
    }

    func testIfFollowsOnRandomEvent() {
        var notesWereDetected = false
        midiNoteDetector.onNoteEventDetected = { timestamp in
            notesWereDetected  = true
        }

        let randomEventIndex = getRandomEventIndexFrom(noteEvents: noteEvents)
        midiNoteDetector.expectedNoteEvent = noteEvents[randomEventIndex]

        guard let noteEvent = midiNoteDetector.expectedNoteEvent else {
            XCTFail()
            return
        }

        for note in noteEvent.notes {
            let message = MIDIMessage.noteOn(key: note, velocity: 10)
            midiNoteDetector.process(midiMessage: message)
        }

        XCTAssertTrue(notesWereDetected)
    }

    func testIfMIDIArrayIsEmptyAfterNoteOff() {


        // add some keys
        midiNoteDetector.process(midiMessage: MIDIMessage.noteOn(key: 69, velocity: 10))
        midiNoteDetector.process(midiMessage: MIDIMessage.noteOn(key: 69+12, velocity: 10))


        // remove keys again
        midiNoteDetector.process(midiMessage: MIDIMessage.noteOff(key: 69, velocity: 10))
        midiNoteDetector.process(midiMessage: MIDIMessage.noteOff(key: 69+12, velocity: 10))


        XCTAssertTrue(midiNoteDetector.currentMIDIKeys.isEmpty)

    }

    func testIfItFollowsWhenSetContainsNotExpectedKeys() {
        var notesWereDetected = false
        midiNoteDetector.onNoteEventDetected = { timestamp in
            notesWereDetected  = true
        }


        let randomEventIndex = getRandomEventIndexFrom(noteEvents: noteEvents)
        midiNoteDetector.expectedNoteEvent = noteEvents[randomEventIndex]

        // add not expected key
        midiNoteDetector.process(midiMessage: .noteOn(key: 0, velocity: 10))

        guard let noteEvent = midiNoteDetector.expectedNoteEvent else {
            XCTFail()
            return
        }

        // add expected keys
        for note in noteEvent.notes {
            midiNoteDetector.process(midiMessage: .noteOn(key: note, velocity: 10))
        }

        XCTAssertTrue(notesWereDetected)
    }

}


func getRandomEventIndexFrom(noteEvents: [NoteEvent]) -> Int {
    let randomEventIndex: Int = randomIntFromRange(lower: 0, upper: noteEvents.count - 1)
    return randomEventIndex
}


func randomIntFromRange (lower: Int, upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
