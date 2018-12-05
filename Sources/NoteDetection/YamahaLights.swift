import Foundation

public class YamahaLights {
    private(set) weak var midiEngine: MIDIEngineProtocol?

    var controller: LightController? {
        didSet {
            if oldValue != nil && controller != nil {
                return // if nothing changed
            }
            onStatusChanged?(status)
        }
        
    }
    
    public var isEnabled: Bool = true {
        didSet {
            switch isEnabled {
                case oldValue: return
                case true: animateLights()
                case false: controller?.turnOffAllLights()
            }
            onStatusChanged?(status)
        }
    }

    public var onStatusChanged: LightControlStatusChangedCallback?
    
    public var status: LightControlStatus {
        let controllerExists = controller != nil
        switch (controllerExists, isEnabled) {
            case (true, true): return .enabled
            case (true, false): return .disabled
            case (false, _): return .notAvailable
        }
    }

    private func animateLights() {
        guard status == .enabled else { return }
        controller?.animateLights { controller in
            controller.turnOnLights(at: self.eventIndex, in: self.noteEvents)
        }
    }

    // MARK: Public API
    public init(midiEngine: MIDIEngineProtocol?) {
        self.midiEngine = midiEngine
        midiEngine?.set(onMIDIOutConnectionsChanged: self.onChangedMIDIOutConnections)
        midiEngine?.set(onSysexMessageReceived: self.onReceiveSysexMessage)
        midiEngine?.midiOutConnections.forEach {
            midiEngine?.send(messages: [YamahaMessages.DUMP_REQUEST_MODEL], to: $0)
        }
    }

    deinit {
        self.controller = nil
    }

    public var noteEvents: [DetectableNoteEvent] = [] {
        didSet { updateLights() }
    }

    public var eventIndex: Int = 0 {
        didSet { updateLights() }
    }
    
    private func updateLights() {
        guard status == .enabled else { return }
        controller?.turnOffAllLights()
        controller?.turnOnLights(at: self.eventIndex, in: self.noteEvents)
    }

    // MARK: Internal API

    func onChangedMIDIOutConnections(outConnections: [MIDIOutConnection]) {
        // kill current light control connection and send a new request to all output connections
        self.controller = nil
        outConnections.forEach {
            midiEngine?.send(messages: [YamahaMessages.DUMP_REQUEST_MODEL], to: $0)
        }
    }

    func onReceiveSysexMessage(data: [UInt8], sourceDevice: MIDIDevice) {
        guard
            let type = YamahaLights.checkIfMessageIsFromDeviceWithLightControl(midiMessageData: data),
            let connection = midiEngine?.midiOutConnections.first(where: { connection in
                return connection.displayName == sourceDevice.displayName
            })
        else { return }

        self.controller = type.toLightController(with: connection, midiEngine: midiEngine)
        self.animateLights()
    }

    // MARK: Statics
    private static func checkIfMessageIsFromDeviceWithLightControl(midiMessageData: [UInt8]) -> ControllerType? {
        guard
            YamahaLights.messageDataIsDumpRequestResponse(midiMessageData),
            let model = YamahaLights.getModelFromDumpRequestResponse(data: midiMessageData)
            else {
                return nil
        }
        if StreamLightController.supportedModels.contains(model) {
            return .StreamLights
        }
        if RegularLightController.supportedModels.contains(model) {
            return .RegularLights
        }
        return nil
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
        let messageDataBegin = [UInt8](data[0 ..< responseSignatureCount])
        return messageDataBegin == YamahaMessages.DUMP_REQUEST_RESPONSE_SIGNATURE
    }
}

private extension YamahaLights {
    private enum ControllerType {
        case RegularLights
        case StreamLights

        func toLightController(with connection: MIDIOutConnection, midiEngine: MIDIEngineProtocol?) -> LightController {
            switch self {
            case .RegularLights: return RegularLightController(connection: connection, midiEngine: midiEngine)
            case .StreamLights: return StreamLightController(connection: connection, midiEngine: midiEngine)
            }
        }
    }
}
