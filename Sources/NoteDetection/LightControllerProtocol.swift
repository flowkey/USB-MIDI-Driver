protocol LightController {
    var midiEngine: MIDIEngineProtocol? { get }
    var connection: MIDIOutConnection? { get }
    var noteEvents: [DetectableNoteEvent] { get set }
    var isEnabled: Bool { get set }
}

extension LightController {
    func send(messages: [[UInt8]]) {
        guard let connection = self.connection else {
            print("light control can not send messages because outConnection does not exist.")
            return
        }
        guard let midiEngine = self.midiEngine else {
            print("light control can not send messages because midiEngine does not exist.")
            return
        }
        midiEngine.send(messages: messages, to: connection)
    }
}
