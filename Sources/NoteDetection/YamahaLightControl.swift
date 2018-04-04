import Foundation

private let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CVP-709GP", "CSP-170", "CSP-150"])

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

class YamahaLightControl {

    let connection: MIDIOutConnection

    // MARK: Public API

    init(connection: MIDIOutConnection) {
        self.connection = connection

        self.switchGuideOn()
        self.switchLightsOnNoSound()
        self.turnOffAllLights()
        self.animateLights()
    }

    private var currentLightningKeys: [UInt8] = [] {
        didSet {
            turnOffAllLights()
            turnOnLights(at: currentLightningKeys)
        }
    }


    var currentLightningNoteEvent: DetectableNoteEvent? {
        didSet {
            if let notes = currentLightningNoteEvent?.notes {
                self.currentLightningKeys = notes.map{ UInt8($0) }
            } else {
                self.currentLightningKeys = []
            }
        }
    }


    // MARK: Statics

    static func checkIfMessageIsFromCompatibleDevice(midiMessageData: [UInt8]) -> Bool {
        guard
            YamahaLightControl.messageDataIsDumpRequestResponse(midiMessageData),
            let model = YamahaLightControl.getModelFromDumpRequestResponse(data: midiMessageData),
            supportedModels.contains(model)
        else {
            return false
        }
        return true
    }

    static func sendClavinovaModelRequest(on connections: [MIDIOutConnection]) {
        connections.forEach { $0.send(messages: [YamahaMessages.DUMP_REQUEST_MODEL]) }
    }

    private static func getModelFromDumpRequestResponse(data: [UInt8]) -> String? {
        let responseDataLength = 16
        guard data.count >= responseDataLength else {
            return nil
        }
        let bytes = data[9 ..< responseDataLength]
        return bytes.reduce("", { result, byte in
            return result + String(UnicodeScalar(byte))
        })
    }

    private static func messageDataIsDumpRequestResponse(_ data: [UInt8]) -> Bool {
        let responseSignatureCount = YamahaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE.count
        guard data.count >= responseSignatureCount else {
            return false
        }
        let messageDataBegin = Array<UInt8>(data[0 ..< responseSignatureCount])
        return messageDataBegin == YamahaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE
    }


    // MARK: Private API

    private func turnOnLights(at keys: [UInt8]) {
        keys.forEach { key in
            let message = self.createNoteOnMessage(channel: LIGHT_CONTROL_CHANNEL, key: key)
            self.connection.send(messages: [message])
        }
    }

    private func turnOffLights(at keys: [UInt8]) {
        keys.forEach { key in
            let message = self.createNoteOffMessage(channel: LIGHT_CONTROL_CHANNEL, key: key)
            self.connection.send(messages: [message])
        }
    }

    private func turnOffAllLights() {
        let noteOffMessages = (0..<128).map { key in
            return self.createNoteOffMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))
        }
        self.connection.send(messages: noteOffMessages)
    }

    private func turnOnAllLights() {
        let noteOnMessages = (0..<128).map { key in
            return self.createNoteOnMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))
        }
        self.connection.send(messages: noteOnMessages)
    }

    private func createNoteOnMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 2) -> [UInt8] {
        return [(NOTE_ON << 4) | LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    private func createNoteOffMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 0) -> [UInt8] {
        return [(NOTE_OFF << 4) | LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    private func switchLightsOnNoSound() {
        self.connection.send(messages: [YamahaMessages.LIGHT_ON_NO_SOUND])
    }

    private func switchLightsOffNoSound() {
        self.connection.send(messages: [YamahaMessages.LIGHT_OFF_NO_SOUND])
    }

    private func switchGuideOff() {
        self.connection.send(messages: [YamahaMessages.GUIDE_OFF])
    }

    private func switchGuideOn() {
        self.connection.send(messages: [YamahaMessages.GUIDE_ON])
    }

    private func animateLights() {
        let keyAnimationTime = 10
        let pianoMIDIRange = 24..<112

        // trigger animation (async)
        for key in pianoMIDIRange {
            let noteOnMsg = self.createNoteOnMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))
            let noteOffMsg = self.createNoteOffMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(key*keyAnimationTime), execute: {
                self.connection.send(messages:[noteOnMsg])
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(key*keyAnimationTime), execute: {
                    self.connection.send(messages:[noteOffMsg])
                })
            })
        }

        // after animation is completed, turn on current lightning keys
        let animationDuration = (pianoMIDIRange.count * keyAnimationTime) * 2
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(animationDuration), execute: {
            self.turnOffAllLights()
            self.turnOnLights(at: self.currentLightningKeys)
        })
    }
}
