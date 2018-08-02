public protocol AudioEngineProtocol: class {
    var sampleRate: Double { get }
    var onSampleRateChanged: SampleRateChangedCallback? { get set }
    func set(onAudioData: AudioDataCallback?)
    func startMicrophone() throws
    func stopMicrophone() throws
}

public protocol MIDIEngineProtocol: class {
    var midiDeviceList: Set<MIDIDevice> { get }
    var midiOutConnections: Array<MIDIOutConnection> { get }
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?)
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?)
    func set(onSysexMessageReceived: SysexMessageReceivedCallback?)
    func set(onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?)
    func send(messages: [[UInt8]], to outConnection: MIDIOutConnection)
}
