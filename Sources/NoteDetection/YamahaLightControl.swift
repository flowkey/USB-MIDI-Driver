import Foundation

private let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CVP-709GP", "CSP-170", "CSP-150"])

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

class YamahaLightControl {

    private let connection: MIDIOutConnection


    // MARK: Public API

    init(connection: MIDIOutConnection) {
        self.connection = connection

        self.switchGuideOn()
        self.switchLightsOnNoSound()
        self.turnOffAllLights()
    }

    var currentLightningKeys: [UInt8] = [] {
        didSet {
            turnOffLights(at: oldValue)
            turnOnLights(at: currentLightningKeys)
        }
    }

    func turnOffAllLights() {
        let noteOffMessages = (0..<128).map { key in
            return self.createNoteOffMessage(channel: SEND_CHANNEL, key: UInt8(key))
        }
        self.connection.send(messages: noteOffMessages)
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
            let message = self.createNoteOnMessage(channel: SEND_CHANNEL, key: key)
            self.connection.send(messages: [message])
        }
    }

    private func turnOffLights(at keys: [UInt8]) {
        keys.forEach { key in
            let message = self.createNoteOffMessage(channel: SEND_CHANNEL, key: key)
            self.connection.send(messages: [message])
        }
    }

    private func createNoteOnMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 2) -> [UInt8] {
        return [(NOTE_ON << 4) | SEND_CHANNEL, key, velocity]
    }

    private func createNoteOffMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 0) -> [UInt8] {
        return [(NOTE_OFF << 4) | SEND_CHANNEL, key, velocity]
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
}
