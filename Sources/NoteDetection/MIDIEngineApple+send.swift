import CoreMIDI

extension MIDIEngine {
    public func send(messages: [[UInt8]], to outConnection: MIDIOutConnection) {
        guard let outConnection = self.midiOutConnections.first(where: { $0 == outConnection }) else {
            print("can not send messages, outConnection was not found")
            return
        }
        
        // Stay under the Clavinova's apparent 256 byte packetList size limit:
        let maxPacketListLength = 64
        
        // send multiple packet lists if messages exceed maxPacketListLength
        for i in stride(from: 0, to: messages.count, by: maxPacketListLength) {
            let messagesToSend = messages.dropFirst(i).prefix(maxPacketListLength)
            guard var packetList = MIDIPacketList(from: Array(messagesToSend)) else {
                assertionFailure("Could not create packetList")
                return
            }
            MIDISend(outConnection.source, outConnection.destination, &packetList)
        }
    }
}


extension MIDIPacketList {
    private static var clavinovaByteLimit = 256 - sizeOfMIDICombinedHeaders
    init?(from midiEvents: [[UInt8]]) {
        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)
        
        for event in midiEvents {
            packet = MIDIPacketListAdd(&packetList, MIDIPacketList.clavinovaByteLimit, packet, mach_absolute_time(), event.count, event)
            
            // Note: Don't believe the compiler warning about this check always
            // returning false, indeed MIDIPacketListAdd() can return nil
            if packet == nil {
                print("There is not enough room in the packet for the event. Split your data into multiple lists.")
                return nil
            }
        }
        
        self = packetList
    }
}
