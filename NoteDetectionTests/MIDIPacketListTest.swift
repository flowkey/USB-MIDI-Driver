import XCTest
import CoreMIDI
@testable import NoteDetection

class MIDIPacketListTest: XCTestCase {
    func testMIDIPacketListInitFromEvents() {
        let midiEvents: [[UInt8]] = [arbitraryNoteOnData, arbitraryNoteOffData, arbitrarySysexData]
        let packetList = MIDIPacketList(from: midiEvents)
        
        var packet = packetList.packet // this is index 0 of the packetList, so start with 1 in the loop below
        let readPackets = [packet] + (1 ..< packetList.numPackets).map { _ in
            packet = MIDIPacketNext(&packet).pointee
            return packet
        }

        XCTAssertEqual(readPackets[0].toMIDIDataArray(), midiEvents[0])
        XCTAssertEqual(readPackets[1].toMIDIDataArray(), midiEvents[1])
        XCTAssertEqual(readPackets[2].toMIDIDataArray(), midiEvents[2])
    }
}

