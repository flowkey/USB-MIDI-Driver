public typealias MIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?, MIDITime) -> Void
public typealias MIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void
public typealias SysexMessageReceivedCallback = ([UInt8], MIDIDevice) -> Void
public typealias MIDIOutConnectionsChangedCallback = ([MIDIOutConnection]) -> Void

public protocol MIDIEngineProtocol: class {
    var midiDeviceList: Set<MIDIDevice> { get }
    var midiOutConnections: Array<MIDIOutConnection> { get }
    func set(onMIDIMessageReceived: MIDIMessageReceivedCallback?)
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?)
    func set(onSysexMessageReceived: SysexMessageReceivedCallback?)
    func set(onMIDIOutConnectionsChanged: MIDIOutConnectionsChangedCallback?)
    func send(messages: [[UInt8]], to outConnection: MIDIOutConnection)
}
