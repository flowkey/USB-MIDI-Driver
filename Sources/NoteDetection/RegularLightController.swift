import Foundation

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

class RegularLightController: LightController {
    static let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CVP-709GP", "CVP-805", "CVP-809"])

    weak var midiEngine: MIDIEngineProtocol?
    weak var connection: MIDIOutConnection?

    private let noteOffMessagesForOctaves: [[[UInt8]]]

    init(connection: MIDIOutConnection?, midiEngine: MIDIEngineProtocol?) {
        self.connection = connection
        self.midiEngine = midiEngine
        self.noteOffMessagesForOctaves = RegularLightController.createLightsOffMessagesPerOctave()

        self.send(messages: [YamahaMessages.GUIDE_ON])
        self.send(messages: [YamahaMessages.LIGHT_ON_NO_SOUND])
    }

    deinit {
        self.turnOffAllLights()
    }

    private func turnOffLights(at noteEvents: [DetectableNoteEvent]) {
        guard let noteEvent = noteEvents.first else { return }
        let messages = noteEvent.notes.map { RegularLightController.createLightOffMessage(key: UInt8($0)) }
        send(messages: messages)
    }

    func turnOnLights(at index: Int, in noteEvents: [DetectableNoteEvent]) {
        if index >= noteEvents.count { return }

        let keys = noteEvents[index].notes.map { UInt8($0) }
        let messages = keys.map { RegularLightController.createLightOnMessage(key: $0) }
        send(messages: messages)
    }

    func turnOffAllLights() {
        self.noteOffMessagesForOctaves.forEach(send)
    }

    static func createLightOnMessage(key: UInt8) -> [UInt8] {
        let velocity: UInt8 = 2
        return [(NOTE_ON << 4) | .LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    static func createLightOffMessage(key: UInt8) -> [UInt8] {
        let velocity: UInt8 = 0
        return [(NOTE_OFF << 4) | .LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    static func createLightsOffMessagesPerOctave() -> [[[UInt8]]] {
        let midiStart = 21
        let midiEnd = 109
        let keysPerOctave = 12
        return stride(from: midiStart, to: midiEnd, by: keysPerOctave).map({ key in
            let end = min(key + keysPerOctave, midiEnd)
            return (key ..< end).map { key in
                return RegularLightController.createLightOffMessage(key: UInt8(key))
            }
        })
    }
}
