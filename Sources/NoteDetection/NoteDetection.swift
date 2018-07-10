public typealias SampleRateChangedCallback = ((_ sampleRate: Double) -> Void)
public typealias AudioDataCallback = (([Float]) -> Void)

public typealias MIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?, Timestamp) -> Void
public typealias MIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void
public typealias SysexMessageReceivedCallback = ([UInt8], MIDIDevice) -> Void
public typealias MIDIOutConnectionsChangedCallback = ([MIDIOutConnection]) -> Void

public protocol NoteEventDelegate: class {
    func onNoteEventDetected(noteDetector: NoteDetector, timestamp: Timestamp) -> Void
}

public protocol InputLevelDelegate: class {
    func onInputLevelChanged(ratio: Float) -> Void
}


/// Common public interface for audio and MIDI note detection
public protocol NoteDetector {
    var noteEventDelegate: NoteEventDelegate? { get set }
    var inputLevelDelegate: InputLevelDelegate? { get set }
    var expectedNoteEvent: DetectableNoteEvent? { get set }
}
