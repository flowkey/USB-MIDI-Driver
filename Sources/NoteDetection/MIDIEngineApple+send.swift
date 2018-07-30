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
            var packetList = MIDIPacketList(from: Array(messagesToSend))
            MIDISend(outConnection.source, outConnection.destination, &packetList)
        }
    }
}


extension MIDIPacketList {
    private static var clavinovaByteLimit = 256
    init(from midiEvents: [[UInt8]]) {
        let totalBytesInAllEvents = midiEvents.reduce(0) { total, event in
            return total + event.count
        }

        // CoreMIDI supports up to 65536 bytes, but the Clavinova doesn't seem to
        assert(totalBytesInAllEvents < MIDIPacketList.clavinovaByteLimit, "The packet list was too long! Split your data into multiple lists.")

        var packetList = MIDIPacketList()
        var packet = MIDIPacketListInit(&packetList)
        midiEvents.forEach { event in
            packet = MIDIPacketListAdd(&packetList, MIDIPacketList.clavinovaByteLimit, packet, mach_absolute_time(), event.count, event)
        }

        self = packetList
    }
}
