public class NoteDetection {
    public typealias InputLevelChangedCallback = ((Float) -> Void)

    var inputType: InputType {
        get { return noteDetector is AudioNoteDetector ? .audio : .midi }
        set {
            noteDetector = createNoteDetector(type: newValue, copy: noteDetector)
            switch noteDetector {
            case let noteDetector as AudioNoteDetector: audioEngine.onAudioData = noteDetector.process
            case let noteDetector as MIDINoteDetector: midiEngine.onMIDIMessageReceived = noteDetector.process
            default: return
            }
        }
    }

    // implicitly unwrapped to be able to use createNoteDetector() in init, which needs self.audioEngine
    var noteDetector: NoteDetector!

    let midiEngine = try! MIDIEngine()
    let audioEngine = try! AudioEngine()

    public var onInputLevelChanged: InputLevelChangedCallback?

    public init(type: InputType) {
        noteDetector = createNoteDetector(type: .audio)

        audioEngine.onSampleRateChanged = { sampleRate in
            if self.inputType == .audio {
                self.noteDetector = self.createNoteDetector(type: .audio, copy: self.noteDetector)
            }
        }
    }
}


// MARK: Public Interface

extension NoteDetection {
    public func set(expectedNoteEvent: DetectableNoteEvent?) {
        noteDetector.expectedNoteEvent = expectedNoteEvent
    }

    public func set(onNoteEventDetected: OnNoteEventDetectedCallback?) {
        noteDetector.onNoteEventDetected = onNoteEventDetected
    }

    public func set(onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback?) {
        midiEngine.onMIDIDeviceListChanged = onMIDIDeviceListChanged
    }

    var noteDetector: NoteDetector
    let audioEngine: AudioEngine
    let midiEngine: MIDIEngine

    public init(type: InputType) throws {
        audioEngine = try AudioEngine() // TODO connect onSampleRateChanged to AudioNoteDetector
        midiEngine = try MIDIEngine()

        //noteDetector = type.createNoteDetector()
        noteDetector = AudioNoteDetector(audioEngine: audioEngine)
    }

    public func startMicrophone() throws {
        try audioEngine.start()
    }

    public func stopMicrophone() throws {
        try audioEngine.stop()
    }

    public func setExpectedNoteEvent(event: DetectableNoteEvent?) {
        noteDetector.setExpectedNoteEvent(noteEvent: event)
    }
}

protocol NoteDetector {
    var onNoteEventDetected: OnNoteEventDetectedCallback? { get set }
    var expectedNoteEvent: DetectableNoteEvent? { get set }
    var onInputLevelChanged: OnInputLevelChangedCallback? { get set }
}

extension NoteDetection {
    func createNoteDetector(type: InputType, copy previousDetector: NoteDetector? = nil) -> NoteDetector {
        var newNoteDetector: NoteDetector
        switch type {
            case .audio: newNoteDetector = AudioNoteDetector(sampleRate: audioEngine.sampleRate)
            case .midi: newNoteDetector = MIDINoteDetector()
        }
        newNoteDetector.expectedNoteEvent = previousDetector?.expectedNoteEvent
        newNoteDetector.onNoteEventDetected = previousDetector?.onNoteEventDetected
        newNoteDetector.onInputLevelChanged = self.onInputLevelChanged
        return newNoteDetector
    }
}

