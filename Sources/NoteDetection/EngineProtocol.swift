public protocol AudioEngineProtocol: class {
    var sampleRate: Double { get }
    func set(onAudioData: AudioDataCallback?)
    func startMicrophone() throws
    func stopMicrophone() throws
}

public protocol MIDIEngineProtocol: class {
    var midiDeviceList: Set<MIDIDevice> { get }
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?)
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?)
    func set(onSysexMessageReceived: SysexMessageReceivedCallback?)
    func set(onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?)
}
