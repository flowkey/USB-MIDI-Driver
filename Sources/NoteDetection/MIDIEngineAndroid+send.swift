extension MIDIEngine {
    public func send(messages: [[UInt8]], to outConnection: MIDIOutConnection) {

    }
    
    public func sendToAllOutConnections(messages: [[UInt8]]) {
        self.midiOutConnections.forEach({
            self.send(messages: messages, to: $0)
        })
    }
}