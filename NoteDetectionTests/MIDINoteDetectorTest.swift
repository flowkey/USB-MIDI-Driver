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

        XCTAssertNil(midiNoteDetector.expectedNoteEvent)
    }

    func testIfMIDIArrayIsEmptyAfterOnFollow() {

        let eventIndex = 0

        midiNoteDetector.expectedNoteEvent = noteEvents[eventIndex]

        for note in midiNoteDetector.expectedNoteEvent!.notes {
            midiNoteDetector.process(midiMessage: MIDIMessage.noteOn(key: note, velocity: 10))
        }

        XCTAssertTrue(midiNoteDetector.currentMIDIKeys.isEmpty)
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

        XCTAssertNil(midiNoteDetector.expectedNoteEvent, "expectedNoteEvent nil because it was detected previously")

    }

}


func getRandomEventIndexFrom(noteEvents: [NoteEvent]) -> Int {
    let randomEventIndex: Int = randomIntFromRange(lower: 0, upper: noteEvents.count - 1)
    return randomEventIndex
}


func randomIntFromRange (lower: Int, upper: Int) -> Int {
    return lower + Int(arc4random_uniform(UInt32(upper - lower + 1)))
}
