import Foundation

private let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CVP-709GP", "CSP-170", "CSP-150"])

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

public class YamahaLightControl {
    private(set) weak var midiEngine: MIDIEngineProtocol?
    
    private(set) weak var connection: MIDIOutConnection? {
        didSet {
            if connection == nil {
                status = .notAvailable
            } else {
                switchGuideOn()
                switchLightsOnNoSound()
                animateLights()
                status = .enabled
            }
        }
    }
    
    public var onStatusChanged: LightControlStatusChangedCallback?
    public var status: LightControlStatus = .notAvailable {
        didSet {
            switch status {
                case .enabled: turnOnLights(at: currentLightningKeys)
                case .disabled: turnOffAllLights()
                case .notAvailable: break
            }
            onStatusChanged?(status)
        }
    }

    // MARK: Public API
    public init(midiEngine: MIDIEngineProtocol) {
        self.midiEngine = midiEngine
        midiEngine.set(onMIDIOutConnectionsChanged: self.onChangedMIDIOutConnections)
        midiEngine.set(onSysexMessageReceived: self.onReceiveSysexMessage)
        midiEngine.sendToAllOutConnections(messages: [YamahaMessages.DUMP_REQUEST_MODEL])
    }
    
    deinit {
        self.turnOffAllLights()
    }

    public var currentLightningNoteEvent: DetectableNoteEvent? {
        didSet {
            if let notes = currentLightningNoteEvent?.notes {
                self.currentLightningKeys = notes.map{ UInt8($0) }
            } else {
                self.currentLightningKeys = []
            }
        }
    }
    
    // MARK: Internal API
    
    func onChangedMIDIOutConnections(outConnections: [MIDIOutConnection]) {
        // kill current light control connection and send a new request to all output connections
        self.connection = nil
        midiEngine?.sendToAllOutConnections(messages: [YamahaMessages.DUMP_REQUEST_MODEL])
    }
    
    func onReceiveSysexMessage(data: [UInt8], sourceDevice: MIDIDevice) {
        guard
            self.checkIfMessageIsFromCompatibleDevice(midiMessageData: data),
            let connection = midiEngine?.midiOutConnections.first(where: { connection in
                return connection.displayName == sourceDevice.displayName
            })
            else { return }
        self.connection = connection
    }
    
    
    // MARK: Private API
    
    private func sendToConnection(messages: [[UInt8]]) {
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
    
    private var currentLightningKeys: [UInt8] = [] {
        didSet {
            turnOffAllLights()
            turnOnLights(at: currentLightningKeys)
        }
    }

    private func checkIfMessageIsFromCompatibleDevice(midiMessageData: [UInt8]) -> Bool {
        guard
            messageDataIsDumpRequestResponse(midiMessageData),
            let model = getModelFromDumpRequestResponse(data: midiMessageData),
            supportedModels.contains(model)
        else {
            return false
        }
        return true
    }

    private func getModelFromDumpRequestResponse(data: [UInt8]) -> String? {
        let responseDataLength = 16
        guard data.count >= responseDataLength else {
            return nil
        }
        let bytes = data[9 ..< responseDataLength]
        return bytes.reduce("", { result, byte in
            return result + String(UnicodeScalar(byte))
        })
    }

    private func messageDataIsDumpRequestResponse(_ data: [UInt8]) -> Bool {
        let responseSignatureCount = YamahaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE.count
        guard data.count >= responseSignatureCount else {
            return false
        }
        let messageDataBegin = Array<UInt8>(data[0 ..< responseSignatureCount])
        return messageDataBegin == YamahaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE
    }


    private func turnOnLights(at keys: [UInt8]) {
        guard status == .enabled
        else { return }
        let noteOnMessages: [[UInt8]] = keys.map{
            createNoteOnMessage(channel: LIGHT_CONTROL_CHANNEL, key: $0)
        }
        sendToConnection(messages: noteOnMessages)
    }

    private func turnOffLights(at keys: [UInt8]) {
        let noteOffMessages: [[UInt8]] = keys.map{
            createNoteOffMessage(channel: LIGHT_CONTROL_CHANNEL, key: $0)
        }
        sendToConnection(messages: noteOffMessages)
    }

    private func turnOffAllLights() {
        let noteOffMessages = (0..<128).map { key in
            return self.createNoteOffMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))
        }
        sendToConnection(messages: noteOffMessages)
    }

    private func turnOnAllLights() {
        let noteOnMessages = (0..<128).map { key in
            return self.createNoteOnMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))
        }
        sendToConnection(messages: noteOnMessages)
    }

    private func createNoteOnMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 2) -> [UInt8] {
        return [(NOTE_ON << 4) | LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    private func createNoteOffMessage(channel: UInt8, key: UInt8, velocity: UInt8 = 0) -> [UInt8] {
        return [(NOTE_OFF << 4) | LIGHT_CONTROL_CHANNEL, key, velocity]
    }

    private func switchLightsOnNoSound() {
        sendToConnection(messages: [YamahaMessages.LIGHT_ON_NO_SOUND])
    }

    private func switchLightsOffNoSound() {
        sendToConnection(messages: [YamahaMessages.LIGHT_OFF_NO_SOUND])
    }

    private func switchGuideOff() {
       sendToConnection(messages: [YamahaMessages.GUIDE_OFF])
    }

    private func switchGuideOn() {
        sendToConnection(messages: [YamahaMessages.GUIDE_ON])
    }

    private func animateLights() {
        let keyAnimationTime = 10
        let pianoMIDIRange = 24..<112

        // trigger animation (async)
        for key in pianoMIDIRange {
            let noteOnMsg = self.createNoteOnMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))
            let noteOffMsg = self.createNoteOffMessage(channel: LIGHT_CONTROL_CHANNEL, key: UInt8(key))

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(key*keyAnimationTime), execute: {
                self.sendToConnection(messages: [noteOnMsg])
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(key*keyAnimationTime), execute: {
                    self.sendToConnection(messages: [noteOffMsg])
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
