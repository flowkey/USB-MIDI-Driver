import FlowCommons

public typealias OnAudioProcessedCallback = (ProcessedAudio) -> Void
public typealias OnVolumeUpdatedCallback = (Float) -> Void
public typealias OnNoteEventDetectedCallback = (Timestamp) -> Void

final class AudioNoteDetection: NoteDetectionProtocol {
    public let inputType: InputType = .audio

    let lowRange: CountableClosedRange<MIDINumber>
    let highRange: CountableClosedRange<MIDINumber>
    let filterbank: FilterBank

    var audioEngine = try! AudioEngine()
    let follower = AudioFollower()

    public let pitchDetection: PitchDetection
    public let onsetDetection: OnsetDetection

    public var onAudioProcessed: OnAudioProcessedCallback?
    public var onVolumeUpdated: OnVolumeUpdatedCallback? // in decibel (-72...0) TODO: maybe move to AudioEngine

    public var onNoteEventDetected: OnNoteEventDetectedCallback? {
        didSet { follower.onFollow = onNoteEventDetected }
    }

    public var onOnsetDetected: OnOnsetDetectedCallback?

    public init () {
        // Chroma extractors for our different ranges:
        lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
        highRange = lowRange.last! ... MIDINumber(note: .d, octave: 7)

        let fullRange = lowRange.first! ... highRange.last!
        filterbank = FilterBank(noteRange: fullRange, sampleRate: audioEngine.sampleRate)

        // Setup processors
        pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!)
        onsetDetection = OnsetDetection(feature: SpectralFlux())

        // Setup follower
        onsetDetection.onOnsetDetected = { timestamp in
            self.follower.onOnsetDetected(timestamp: timestamp)
            self.onOnsetDetected?(timestamp)
        }
        pitchDetection.onPitchDetected = follower.onPitchDetected
        follower.onFollow = onNoteEventDetected
    }

    deinit {
        print("deiniting AudioNoteDetection")
    }

    public func start() {
        audioEngine.onAudioData = self.process
        try! audioEngine.start()
    }

    public func stop() {
        try! audioEngine.stop()
    }

    /// Creates a new AudioNoteDetection preserving existing delegates, but with a different sampleRate.
    func cloned(newSampleRate sampleRate: Double) -> AudioNoteDetection {
        let copy = AudioNoteDetection()
        copy.onAudioProcessed = self.onAudioProcessed
        copy.onVolumeUpdated = self.onVolumeUpdated
        return copy
    }

    var volumeIteration = 0

    func process(audio buffer: [Float]) {
        let volume = linearToDecibel(rootMeanSquare(buffer))

        volumeIteration += 1
        if volumeIteration > 11 { // this value is tuned to make the NativeInputManager look nice
            if let callback = onVolumeUpdated, volume.isFinite {
               performOnMainThread { callback(volume) }
            }
            volumeIteration = 0
        }

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        guard volume > -48 || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
            return // print("Too quiet, not detecting")
        }

        // Do Pitch / Onset Detection
        filterbank.calculateMagnitudes(buffer)
        let onsetData = onsetDetection.run(buffer, filterbankMagnitudes: filterbank.magnitudes)
        let chromaVector = chroma(pitchDetection.currentDetectionMode)
        pitchDetection.run(chromaVector)

        performOnMainThread { self.onAudioProcessed?(ProcessedAudio(
            audioData: buffer,
            chromaVector: chromaVector.toRaw,
            filterBandAmplitudes: self.filterbank.magnitudes,
            onsetFeatureValue: onsetData.featureValue,
            onsetThreshold: onsetData.currentThreshold,
            onsetDetected: onsetData.onsetDetected
        ))}
    }

    public func setExpectedNoteEvent(noteEvent: NoteEvent?) {
        pitchDetection.expectedPitchDetectionData = PitchDetectionData(from: noteEvent)
    }

    func chroma(_ detectionMode: PitchDetection.DetectionMode) -> ChromaVector {

        // These only get calculated if you actually access them:
        /// Extracted from filterbank magnitudes within __LOW__ range
        var lowChroma: ChromaVector {
            return ChromaVector(from: filterbank.magnitudes, startingAt: lowRange.first!, range: lowRange)
        }

        /// Extracted from filterbank magnitudes within __HIGH__ range
        var highChroma: ChromaVector {
             return ChromaVector(from: filterbank.magnitudes, startingAt: lowRange.first!, range: highRange)
        }

        switch detectionMode {
            case .lowPitches:  return lowChroma
            case .highPitches: return highChroma
            case .highAndLow:  return lowChroma + highChroma
        }
    }
}
