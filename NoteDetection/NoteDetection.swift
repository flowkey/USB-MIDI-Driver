public typealias InputLevelChangedCallback = ((Float) -> Void)
public typealias SampleRateChangedCallback = ((_ sampleRate: Double) -> Void)

public class NoteDetection {
    public var isEnabled = true

    var onInputLevelChanged: InputLevelChangedCallback?

    var noteDetector: NoteDetector! // implicitly unwrapped so we can use self.createNoteDetector() on init
    let audioEngine: AudioEngine
    let midiEngine: MIDIEngine

    fileprivate var ignoreUntilDeadline: Timestamp?

    /// This used to have an implicit `at timestamp` of `.now`. That was incorrect. We
    /// want to compare with the timestamp of the potential notesDetected event, which
    /// could either be slightly before .now because of async code, or mocked in tests:
    fileprivate func isIgnoring(at timestamp: Timestamp) -> Bool {
        guard let deadline = ignoreUntilDeadline else { return false }
        return (timestamp - deadline) < 0
    }

    public init(input: InputType) throws {
        midiEngine = try MIDIEngine()
        audioEngine = try AudioEngine()

        noteDetector = createNoteDetector(type: input)
        audioEngine.onSampleRateChanged = onSampleRateChanged
    }

    private func onSampleRateChanged(sampleRate: Double) {
        if noteDetector is AudioNoteDetector { // don't switch away from midi just because the sampleRate changed
            noteDetector = createNoteDetector(type: .audio)
        }
    }

    func createNoteDetector(type: InputType) -> NoteDetector {
        var newNoteDetector: NoteDetector
        switch type {
        case .audio: newNoteDetector = AudioNoteDetector(input: audioEngine)
        case .midi: newNoteDetector = MIDINoteDetector(input: midiEngine)
        }

        // Transfer all callbacks from the previous detector over to the new one:
        newNoteDetector.expectedNoteEvent = noteDetector?.expectedNoteEvent
        newNoteDetector.onNoteEventDetected = noteDetector?.onNoteEventDetected
        newNoteDetector.onInputLevelChanged = self.onInputLevelChanged

        return newNoteDetector
    }
}

// MARK: Public Interface

extension NoteDetection {
    public var inputType: InputType {
        get { return noteDetector is AudioNoteDetector ? .audio : .midi }
        set { noteDetector = createNoteDetector(type: newValue) }
    }

    public var midiDeviceList: Set<MIDIDevice> {
        return midiEngine.midiDeviceList
    }

    public func set(onInputLevelChanged: InputLevelChangedCallback?) {
        self.onInputLevelChanged = onInputLevelChanged
    }

    public func set(expectedNoteEvent: DetectableNoteEvent?) {
        noteDetector.expectedNoteEvent = expectedNoteEvent
    }

    public func set(onNoteEventDetected: NoteEventDetectedCallback?) {
        noteDetector.onNoteEventDetected = { [unowned self] timestamp in
            // unowned self, otherwise noteDetector 'owns' self and vice-versa (ref cycle)
            if self.isEnabled, !self.isIgnoring(at: timestamp) {
                onNoteEventDetected?(timestamp)
            }
        }
    }

    public func ignoreFor(ms duration: Double) {
        ignoreUntilDeadline = .now + duration
    }

    public func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {
        midiEngine.set(onMIDIDeviceListChanged: onMIDIDeviceListChanged)
    }

    public func startMicrophone() throws {
        try audioEngine.start()
    }

    public func stopMicrophone() throws {
        try audioEngine.stop()
    }
}

protocol NoteDetector {
    var onNoteEventDetected: NoteEventDetectedCallback? { get set }
    var expectedNoteEvent: DetectableNoteEvent? { get set }
    var onInputLevelChanged: InputLevelChangedCallback? { get set }
}
