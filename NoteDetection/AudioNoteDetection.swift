private let timeToNextToleranceFactor = 0.5

public typealias NoteEventDetectedCallback = (Timestamp) -> Void

final class AudioNoteDetector: NoteDetector {
    static let maxTimestampDiff = Timestamp(200)

    var expectedNoteEvent: DetectableNoteEvent? {
        didSet { pitchDetection.setExpectedEvent(expectedNoteEvent) }
    }

    let filterbank: FilterBank
    var pitchDetection: PitchDetection!
    var onsetDetection: OnsetDetection!

    var onInputLevelChanged: InputLevelChangedCallback?
    var onAudioProcessed: AudioProcessedCallback?
    var onOnsetDetected: OnsetDetectedCallback?

    init(sampleRate: Double) {
        // Chroma extractors for our different ranges:
        let lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
        let highRange = lowRange.last! ... MIDINumber(note: .d, octave: 7)

        // Setup processors
        filterbank = FilterBank(lowRange: lowRange, highRange: highRange, sampleRate: sampleRate)
        pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!, onPitchDetected: self.onPitchDetected)
        onsetDetection = OnsetDetection(feature: SpectralFlux(), onOnset: self.onOnsetDetected)
    }

    convenience init(engine: AudioEngine) {
        self.init(sampleRate: engine.sampleRate)
        engine.onAudioData = self.process
    }

    var volumeIteration = 0
    private func calculateVolume(from buffer: [Float]) -> Float {
        let volume = linearToDecibel(rootMeanSquare(buffer))

        volumeIteration += 1
        if volumeIteration > 11 { // this value is tuned to make the NativeInputManager look nice
            if let onInputLevelChanged = onInputLevelChanged, volume.isFinite {
                // wanna calculate dBFS reference value? this could be helpful https://goo.gl/rzCeAW
                let ratio = 1 - (volume / -96)
                performOnMainThread { onInputLevelChanged(ratio) }
            }
            volumeIteration = 0
        }

        return volume
    }

    func process(audio buffer: [Float]) {
        let volume = calculateVolume(from: buffer)

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        guard volume > -48 || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
            return // print("Too quiet, not detecting")
        }

        // Do Pitch / Onset Detection
        filterbank.calculateMagnitudes(buffer)
        let onset = onsetDetection.run(buffer, filterbankMagnitudes: filterbank.magnitudes)
        let chromaVector = filterbank.getChroma(for: pitchDetection.currentDetectionMode)
        pitchDetection.run(chromaVector)

        // Don't make unnecessary calls to the main thread if there is no callback set:
        if let onAudioProcessed = onAudioProcessed {
            performOnMainThread {
                let filterbankMagnitudes = self.filterbank.magnitudes
                onAudioProcessed(
                    (buffer, chromaVector, filterbankMagnitudes, onset.featureValue, onset.threshold, onset.wasDetected)
                )
            }
        }
    }

    private var lastOnsetTimestamp: Timestamp?
    private var lastNoteTimestamp: Timestamp?
    private var lastFollowEventTime: Timestamp?

    public var onNoteEventDetected: NoteEventDetectedCallback?

    public func onOnsetDetected(timestamp: Timestamp) {
        guard currentlyAcceptingOnsets() else { return }
        lastOnsetTimestamp = timestamp
        onInputReceived()
    }

    public func onPitchDetected(timestamp: Timestamp) {
        lastNoteTimestamp = timestamp
        onInputReceived()
    }

    func currentlyAcceptingOnsets() -> Bool {
        if let lastFollowEventTime = lastFollowEventTime, let timeToNextEvent = expectedNoteEvent?.timeToNext {
            return .now - lastFollowEventTime >= (timeToNextEvent * timeToNextToleranceFactor)
        } else {
            return true
        }
    }

    func onInputReceived() {
        if timestampsAreCloseEnough() {
            expectedNoteEvent = nil // onNoteEventDetected sets new event, so setting it to nil must happen before
            self.lastFollowEventTime = .now
            self.lastOnsetTimestamp = nil
            self.lastNoteTimestamp = nil

            onNoteEventDetected?(.now)
        }
    }

    private func timestampsAreCloseEnough() -> Bool {
        guard
            let onsetTimestamp = lastOnsetTimestamp,
            let noteTimestamp = lastNoteTimestamp
            else { return false }

        let timestampDiff = abs(onsetTimestamp - noteTimestamp)
        return timestampDiff < AudioNoteDetector.maxTimestampDiff
    }
}
