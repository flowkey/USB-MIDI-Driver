public typealias NoteEventDetectedCallback = (Timestamp) -> Void

final class AudioNoteDetector: NoteDetector {
    static let maxTimestampDiff = Timestamp(150)

    var expectedNoteEvent: DetectableNoteEvent? {
        didSet { pitchDetection.setExpectedEvent(expectedNoteEvent) }
    }

    let filterbank: FilterBank
    var pitchDetection: PitchDetection!
    var onsetDetection: OnsetDetection!

    var onInputLevelChanged: InputLevelChangedCallback?
    var onAudioProcessed: AudioProcessedCallback?

    init(sampleRate: Double) {
        // Chroma extractors for our different ranges:
        let lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
        let highRange = lowRange.last! ... MIDINumber(note: .d, octave: 7)

        // Setup processors
        filterbank = FilterBank(lowRange: lowRange, highRange: highRange, sampleRate: sampleRate)
        pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!, onPitchDetected: self.onPitchDetected)
        onsetDetection = OnsetDetection(feature: SpectralFlux(), onOnset: self.onOnsetDetected)
    }

    convenience init(input: AudioInput) {
        self.init(sampleRate: input.sampleRate)
        input.set(onAudioData: self.process)
    }

    /// The volume level above which the pitch detection is activated and reported volume increases above 0.
    /// In reality our noise floor is closer to -96dB, but this value seems to work well not only save power
    /// but also to show a reasonable range of volume for our application.
    let volumeLowerThreshold: Float = -48

    var volumeIteration = 0
    private func calculateVolume(from buffer: [Float]) -> Float {
        let volume = linearToDecibel(rootMeanSquare(buffer))

        volumeIteration += 1
        if volumeIteration >= 3 { // avoid overloading the main thread unnecessarily
            if let onInputLevelChanged = onInputLevelChanged, volume.isFinite {
                // wanna calculate dBFS reference value? this could be helpful https://goo.gl/rzCeAW
                let ratio = 1 - (volume / volumeLowerThreshold)
                let ratioBetween0and1 = min(max(0, ratio), 1)
                performOnMainThread { onInputLevelChanged(ratioBetween0and1) }
            }
          volumeIteration = 0
        }

        return volume
    }

    func process(audio buffer: [Float]) {
        let volume = calculateVolume(from: buffer)

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        guard volume > volumeLowerThreshold || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
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

    func onOnsetDetected(timestamp: Timestamp) {
        lastOnsetTimestamp = timestamp
        onInputReceived()
    }

    func onPitchDetected(timestamp: Timestamp) {
        lastNoteTimestamp = timestamp
        onInputReceived()
    }

    func onInputReceived() {
        if timestampsAreCloseEnough() {
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
