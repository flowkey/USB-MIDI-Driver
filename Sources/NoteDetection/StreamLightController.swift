import Foundation

class StreamLightController: LightController {
    static let supportedModels = Set(["CSP-170", "CSP-150"])

    weak var midiEngine: MIDIEngineProtocol?
    weak var connection: MIDIOutConnection?

    func turnOnLights(at index: Int, in noteEvents: [DetectableNoteEvent]) {
        if index >= noteEvents.count { return }
        
        let nextNoteEvents = // get the next upcoming 4 note events which contain notes
            noteEvents[index...]
            .lazy
            .filter{ $0.notes.count > 0 }
            .prefix(4)

        for (ledRow, noteEvent) in nextNoteEvents.enumerated() {
            let keys = noteEvent.notes.map{ UInt8($0) }
            let mode: LEDMode = (ledRow == 0) ? .flash : .on
            keys.forEach { key in
                let message = createStreamLightsOnOffMessage(key: key, ledRow: UInt8(ledRow), mode: mode)
                send(messages: [message])
            }
        }
    }

    init(connection: MIDIOutConnection?, midiEngine: MIDIEngineProtocol?) {
        self.connection = connection
        self.midiEngine = midiEngine
    }

    deinit {
        self.turnOffAllLights()
    }

    func turnOffAllLights() {
        self.send(messages: [YamahaMessages.TURN_OFF_ALL_STREAM_LIGHTS])
    }
}

// These messages are used for the starting animation only because they only affect the first row:
extension StreamLightController {
    func createLightOnMessage(key: UInt8) -> [UInt8] {
        return createStreamLightsOnOffMessage(key: key, ledRow: 0, mode: .on)
    }

    func createLightOffMessage(key: UInt8) -> [UInt8] {
        return createStreamLightsOnOffMessage(key: key, ledRow: 0, mode: .off)
    }
}
