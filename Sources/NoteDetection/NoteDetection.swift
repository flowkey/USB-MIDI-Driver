public typealias InputLevelChangedCallback = ((Float) -> Void)
public typealias SampleRateChangedCallback = ((_ sampleRate: Double) -> Void)
public typealias AudioDataCallback = (([Float]) -> Void)

public typealias MIDIMessageReceivedCallback = (MIDIMessage, MIDIDevice?, Timestamp) -> Void
public typealias MIDIDeviceListChangedCallback = (Set<MIDIDevice>) -> Void
public typealias SysexMessageReceivedCallback = ([UInt8], MIDIDevice) -> Void
public typealias MIDIOutConnectionsChangedCallback = ([MIDIOutConnection]) -> Void

public enum InputType {
    case audio
    case midi
}

public class NoteDetection {
    var noteDetector: NoteDetector! // implicitly unwrapped so we can use self.createNoteDetector() on init
    fileprivate var ignoreUntilDeadline: Timestamp?

    fileprivate func isIgnoring(at timestamp: Timestamp) -> Bool {
        guard let deadline = ignoreUntilDeadline else { return false }
        return (timestamp - deadline) < 0
    }

    public init(input: InputType, audioSampleRate: Double) {
        sampleRate = audioSampleRate
        noteDetector = createNoteDetector(type: input)
    }

    var sampleRate: Double {
        didSet {
            if noteDetector is AudioNoteDetector { // don't switch away from midi just because the sampleRate changed
                noteDetector = createNoteDetector(type: .audio)
            }
        }
    }

    func createNoteDetector(type: InputType) -> NoteDetector {
        var newNoteDetector: NoteDetector
        switch type {
        case .audio: newNoteDetector = AudioNoteDetector(sampleRate: self.sampleRate)
        case .midi: newNoteDetector = MIDINoteDetector()
        }

        // Transfer all callbacks from the previous detector over to the new one:
        newNoteDetector.expectedNoteEvent = noteDetector?.expectedNoteEvent
        newNoteDetector.onNoteEventDetected = noteDetector?.onNoteEventDetected
        newNoteDetector.onInputLevelChanged = noteDetector?.onInputLevelChanged

        return newNoteDetector
    }
}

extension NoteDetection {
    public var inputType: InputType {
        get { return noteDetector is AudioNoteDetector ? .audio : .midi }
        set { noteDetector = createNoteDetector(type: newValue) }
    }

    public func set(expectedNoteEvent: DetectableNoteEvent?) {
        noteDetector.expectedNoteEvent = expectedNoteEvent
    }

    public func set(onNoteEventDetected: NoteEventDetectedCallback?) {
        noteDetector.onNoteEventDetected = { [unowned self] timestamp in
            // unowned self, otherwise noteDetector 'owns' self and vice-versa (ref cycle)
            if !self.isIgnoring(at: timestamp) {
                // onDetected sets the next event in most cases (except at end of song),
                // so we need to nil the event before running it to avoid overwriting the new event
                self.noteDetector.expectedNoteEvent = nil
                onNoteEventDetected?(timestamp)
            }
        }
    }

    public func set(onInputLevelChanged: InputLevelChangedCallback?) {
        noteDetector.onInputLevelChanged = onInputLevelChanged
    }

    public func ignoreFor(ms duration: Double) {
        ignoreUntilDeadline = .now + duration
    }

    public func process(audioData: [Float]) {
        guard let audioNoteDetector = (self.noteDetector as? AudioNoteDetector) else {
            return
        }
        audioNoteDetector.process(audio: audioData)
    }

    public func process(midiMessage: MIDIMessage) {
        guard let midiNoteDetector = (self.noteDetector as? MIDINoteDetector) else {
            return
        }
        midiNoteDetector.process(midiMessage: midiMessage)
    }
}


/// Common public interface for audio and MIDI note detection
protocol NoteDetector {
    var onNoteEventDetected: NoteEventDetectedCallback? { get set }
    var expectedNoteEvent: DetectableNoteEvent? { get set }
    var onInputLevelChanged: InputLevelChangedCallback? { get set }
}
