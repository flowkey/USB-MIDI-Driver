import Foundation

private let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CSP-170", "CSP-150"])

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

private let midiChannel: UInt8 = 10

class LightControl {
    let connection: MIDIOutConnection

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

    static func messageWasSendByCompatibleDevice(midiMessageData: [UInt8]) -> Bool {
        guard
            LightControl.messageDataIsDumpRequestResponse(midiMessageData),
            let model = LightControl.getModelFromDumpRequestResponse(data: midiMessageData),
            LightControl.modelHasLightControlSupport(model: model)
        else {
            return false
        }
        return true
    }

    static func sendClavinovaModelRequest(on connections: [MIDIOutConnection]) {
        connections.forEach { $0.sendSysex(ClavinovaMessages.DUMP_REQUEST_MODEL) }
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

    private static func modelHasLightControlSupport(model: String) -> Bool {
        return supportedModels.contains(model)
    }

    private static func messageDataIsDumpRequestResponse(_ data: [UInt8]) -> Bool {
        let responseSignatureCount = ClavinovaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE.count
        guard data.count >= responseSignatureCount else {
            return false
        }
        let messageDataBegin = Array<UInt8>(data[0 ..< responseSignatureCount])
        return messageDataBegin == ClavinovaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE
    }

    private func turnOnLights(at keys: [UInt8]) {
        keys.forEach { key in
            let message = self.createNoteOnMessage(channel: midiChannel, key: key)
            self.connection.send(messages: [message])
        }
    }

    private func turnOffLights(at keys: [UInt8]) {
        keys.forEach { key in
            let message = self.createNoteOffMessage(channel: midiChannel, key: key)
            self.connection.send(messages: [message])
        }
    }

    func turnOffAllLights() {
        let noteOffMessages = (0..<128).map { key in
            return self.createNoteOffMessage(channel: midiChannel, key: UInt8(key))
        }
        self.connection.send(messages: noteOffMessages)
    }

    private func createNoteOnMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 2) -> [UInt8] {
        return [(NOTE_ON << 4) | midiChannel, key, velocity]
    }

    private func createNoteOffMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 0) -> [UInt8] {
        return [(NOTE_OFF << 4) | midiChannel, key, velocity]
    }

    private func switchLightsOnNoSound() {
        self.connection.sendSysex(ClavinovaMessages.LIGHT_ON_NO_SOUND)
    }

    private func switchLightsOffNoSound() {
        self.connection.sendSysex(ClavinovaMessages.LIGHT_OFF_NO_SOUND)
    }

    private func switchGuideOff() {
        self.connection.sendSysex(ClavinovaMessages.GUIDE_OFF)
    }

    private func switchGuideOn() {
        self.connection.sendSysex(ClavinovaMessages.GUIDE_ON)
    }
}
