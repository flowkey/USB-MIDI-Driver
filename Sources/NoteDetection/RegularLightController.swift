import Foundation

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

class RegularLightController: LightController {
    static let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CVP-709GP"])

    weak var midiEngine: MIDIEngineProtocol?
    weak var connection: MIDIOutConnection?

    init(connection: MIDIOutConnection?, midiEngine: MIDIEngineProtocol?) {
        self.connection = connection
        self.midiEngine = midiEngine

        self.send(messages: [YamahaMessages.GUIDE_ON])
        self.send(messages: [YamahaMessages.LIGHT_ON_NO_SOUND])
    }

    deinit {
        self.turnOffAllLights()
    }

    private func turnOffLights(at noteEvents: [DetectableNoteEvent]) {
        guard let noteEvent = noteEvents.first else { return }
        let messages = noteEvent.notes.map { createLightOffMessage(key: UInt8($0)) }
        send(messages: messages)
    }

    func turnOnLights(at index: Int, in noteEvents: [DetectableNoteEvent]) {
        if index >= noteEvents.count { return }

        let keys = noteEvents[index].notes.map{ UInt8($0) }
        let messages = keys.map { createLightOnMessage(key: $0) }
        send(messages: messages)
    }

    func turnOffAllLights() {
        (0 ..< 128).forEach {
            let message = createLightOffMessage(key: UInt8($0))
            send(messages: [message])
        }
    }

    func createLightOnMessage(key: UInt8) -> [UInt8] {
        let velocity: UInt8 = 2
        return [(NOTE_ON << 4) | .LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    func createLightOffMessage(key: UInt8) -> [UInt8] {
        let velocity: UInt8 = 0
        return [(NOTE_OFF << 4) | .LIGHT_CONTROL_CHANNEL, key, velocity]
    }
}
