private let timeToNextToleranceFactor = 0.5
private let maxTimestampDiff = Timestamp(200)

public typealias OnAudioProcessedCallback = (ProcessedAudio) -> Void
public typealias OnVolumeUpdatedCallback = (Float) -> Void
public typealias OnNoteEventDetectedCallback = (Timestamp) -> Void

final class AudioNoteDetector: NoteDetector {
    let lowRange: CountableClosedRange<MIDINumber>
    let highRange: CountableClosedRange<MIDINumber>
    let filterbank: FilterBank

    var pitchDetection: PitchDetection!
    var onsetDetection: OnsetDetection!

    public var onAudioProcessed: OnAudioProcessedCallback?
    public var onVolumeUpdated: OnVolumeUpdatedCallback? // in decibel (-72...0)
    public var onOnsetDetected: OnOnsetDetectedCallback?

    public init (sampleRate: Double) {
        // Chroma extractors for our different ranges:
        lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
        highRange = lowRange.last! ... MIDINumber(note: .d, octave: 7)

        let fullRange = lowRange.first! ... highRange.last!
        filterbank = FilterBank(noteRange: fullRange, sampleRate: sampleRate)

        // Setup processors
        pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!, onPitchDetected: self.onPitchDetected)
        onsetDetection = OnsetDetection(feature: SpectralFlux(), onOnset: self.onOnsetDetected)
    }

    /// Creates a new AudioNoteDetection preserving existing delegates, but with a different sampleRate.
    func cloned(newSampleRate: Double) -> AudioNoteDetector {
        let copy = AudioNoteDetector(sampleRate: newSampleRate)
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

        performOnMainThread {
            self.onAudioProcessed?(
                ProcessedAudio(
                    audioData: buffer,
                    chromaVector: chromaVector.toRaw,
                    filterBandAmplitudes: self.filterbank.magnitudes,
                    onsetFeatureValue: onsetData.featureValue,
                    onsetThreshold: onsetData.currentThreshold,
                    onsetDetected: onsetData.onsetDetected
                )
            )
        }
    }

    public var expectedNoteEvent: NoteEvent? {
        didSet { pitchDetection.expectedPitchDetectionData = PitchDetectionData(from: expectedNoteEvent) }
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

    private var lastOnsetTimestamp: Timestamp?
    private var lastNoteTimestamp: Timestamp?
    private var lastFollowEventTime: Timestamp?

    public var onNoteEventDetected: OnNoteEventDetectedCallback?

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
        guard
            let lastFollowEventTime = lastFollowEventTime,
            let timeToNextEvent = expectedNoteEvent?.timeToNext
            else {
                return true
        }
        return .now - lastFollowEventTime >= (timeToNextEvent * timeToNextToleranceFactor)
    }

    func onInputReceived() {
        if timestampsAreCloseEnough() {
            onNoteEventDetected?(.now)
            expectedNoteEvent = nil
            self.lastFollowEventTime = .now
            self.lastOnsetTimestamp = nil
            self.lastNoteTimestamp = nil
        }
    }

    private func timestampsAreCloseEnough() -> Bool {
        guard
            let onsetTimestamp = lastOnsetTimestamp,
            let noteTimestamp = lastNoteTimestamp
            else { return false }

        let timestampDiff = abs(onsetTimestamp - noteTimestamp)
        return timestampDiff < maxTimestampDiff
    }
}
