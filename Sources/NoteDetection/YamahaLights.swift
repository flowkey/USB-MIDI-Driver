import Foundation

public class YamahaLights {
    private(set) weak var midiEngine: MIDIEngineProtocol?

    private var controller: LightController? {
        didSet {
            if oldValue != nil && controller != nil {
                return // if nothing changed
            }
            status = (controller == nil) ? .notAvailable : .enabled
        }
    }
    
    public func set(isEnabled: Bool) {
        status = isEnabled ? .enabled : .disabled
    }
    
    public var onStatusChanged: LightControlStatusChangedCallback?
    private(set) public var status: LightControlStatus = .notAvailable {
        didSet {
            switch status {
            case .enabled: controller?.isEnabled = true
            case .disabled: controller?.isEnabled = false
            case .notAvailable:
                if controller != nil {
                    assertionFailure("light controller should be nil but is not")
                }
            }
            onStatusChanged?(status)
        }
    }

    // MARK: Public API
    public init(midiEngine: MIDIEngineProtocol) {
        self.midiEngine = midiEngine
        midiEngine.set(onMIDIOutConnectionsChanged: self.onChangedMIDIOutConnections)
        midiEngine.set(onSysexMessageReceived: self.onReceiveSysexMessage)
        midiEngine.midiOutConnections.forEach {
            midiEngine.send(messages: [YamahaMessages.DUMP_REQUEST_MODEL], to: $0)
        }
    }
    
    deinit {
        self.controller = nil
    }

    public var noteEvents: [DetectableNoteEvent] {
        get { return [] }
        set { controller?.noteEvents = newValue }
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
        let messageDataBegin = Array<UInt8>(data[0 ..< responseSignatureCount])
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
