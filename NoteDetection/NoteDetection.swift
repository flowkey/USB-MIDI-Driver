public typealias InputLevelChangedCallback = ((Float) -> Void)
public typealias SampleRateChangedCallback = ((_ sampleRate: Double) -> Void)

public class NoteDetection {
    var onInputLevelChanged: InputLevelChangedCallback?

    var noteDetector: NoteDetector! // implicitly unwrapped so we can use self.createNoteDetector() on init
    let audioEngine: AudioEngine
    let midiEngine: MIDIEngine

    public init() throws {
        midiEngine = try MIDIEngine()
        audioEngine = try AudioEngine()

        let initialInputType: InputType = midiEngine.isReadyToReceiveMessages ? .midi : .audio
        noteDetector = createNoteDetector(type: initialInputType)

        audioEngine.onSampleRateChanged = onSampleRateChanged
        self.set(onMIDIDeviceListChanged: nil)
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

    public var inputType: InputType { // noteDetection.input = .audio
        get { return noteDetector is AudioNoteDetector ? .audio : .midi }
        set { noteDetector = createNoteDetector(type: newValue) }
    }

    public func set(onInputLevelChanged: InputLevelChangedCallback?) {
        self.onInputLevelChanged = onInputLevelChanged
    }

    public func set(expectedNoteEvent: DetectableNoteEvent?) {
        noteDetector.expectedNoteEvent = expectedNoteEvent
    }

    public func set(onNoteEventDetected: NoteEventDetectedCallback?) {
        noteDetector.onNoteEventDetected = onNoteEventDetected
    }

    public func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?) {
        midiEngine.set(onMIDIDeviceListChanged: { midiDeviceList in
            self.inputType = midiDeviceList.count < 1 ? .audio : .midi
            onMIDIDeviceListChanged?(midiDeviceList)
        })
    }

    public func startMicrophone() throws {
        try audioEngine.start()
    }

    public func stopMicrophone() throws {
        try audioEngine.stop()
    }

    public func overrideInputType(to type: InputType) {
        noteDetector = createNoteDetector(type: type)
    }
}

protocol NoteDetector {
    var onNoteEventDetected: NoteEventDetectedCallback? { get set }
    var expectedNoteEvent: DetectableNoteEvent? { get set }
    var onInputLevelChanged: InputLevelChangedCallback? { get set }
}

extension MIDIEngine {
    var isReadyToReceiveMessages: Bool { return self.midiDeviceList.count > 0 }
}
