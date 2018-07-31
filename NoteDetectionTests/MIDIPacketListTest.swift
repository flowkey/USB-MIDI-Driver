import XCTest
import CoreMIDI
@testable import NoteDetection

class MIDIPacketListTest: XCTestCase {
    func testMIDIPacketListInitFromEvents() {
        let midiEvents: [[UInt8]] = [arbitraryNoteOnData, arbitraryNoteOffData, arbitrarySysexData]
        guard let packetList = MIDIPacketList(from: midiEvents) else {
            XCTFail("Could not create packetList")
            return
        }
        
        var packet = packetList.packet // this is index 0 of the packetList, so start with 1 in the loop below
        let packets: [MIDIPacket] = [packet] + (1 ..< packetList.numPackets).map { _ in
            packet = MIDIPacketNext(&packet).pointee
            return packet
        }

        XCTAssertEqual(packets[0].toMIDIDataArray(), midiEvents[0])
        XCTAssertEqual(packets[1].toMIDIDataArray(), midiEvents[1])
        XCTAssertEqual(packets[2].toMIDIDataArray(), midiEvents[2])
    }
    
    func testInitLongMIDIPacketListWithoutCrashing() {
        let midiEvents: [[UInt8]] = [[UInt8]](repeating: arbitraryNoteOnData, count: 1000)
        
        guard let packetList = MIDIPacketList(from: midiEvents) else {
            print("Could not create packetList but at least did not crash")
            return
        }
        
        print("Could create packetList and did not crash: ", packetList)
    }
}

