public typealias OnAudioProcessedCallback = (ProcessedAudio) -> Void
public typealias OnVolumeUpdatedCallback = (Float) -> Void

final public class AudioNoteDetection: NoteDetectionProtocol {


    // TODO: implement things
    public var onEventDetected: (() -> Void)?

    public func start() {

    }

    public func stop() {

    }

    public let inputType: InputType = .audio


    let lowRange: CountableClosedRange<MIDINumber>
    let highRange: CountableClosedRange<MIDINumber>

    let filterbank: FilterBank
    public let pitchDetection: PitchDetection
    public let onsetDetection: OnsetDetection

    public var onAudioProcessed: OnAudioProcessedCallback?
    public var onVolumeUpdated: OnVolumeUpdatedCallback?

    init (sampleRate: Double) {
        // Chroma extractors for our different ranges:
        lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
        highRange = lowRange.last! ... MIDINumber(note: .d, octave: 7)

        let fullRange = lowRange.first! ... highRange.last!

        // Setup processors
        filterbank = FilterBank(noteRange: fullRange, sampleRate: sampleRate)
        pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!)
        onsetDetection = OnsetDetection(feature: SpectralFlux())
    }

    /// Creates a new AudioNoteDetection preserving existing delegates, but with a different sampleRate.
    func cloned(newSampleRate sampleRate: Double) -> AudioNoteDetection {
        let copy = AudioNoteDetection(sampleRate: sampleRate)
        copy.onAudioProcessed = self.onAudioProcessed
        copy.onVolumeUpdated = self.onVolumeUpdated
        return copy
    }

    var volumeIteration = 0

    func process(audio buffer: [Float]) {
        let volume = linearToDecibel(rootMeanSquare(buffer))

        volumeIteration += 1
        if volumeIteration > 11 { // this value is tuned to make the NativeInputManager look nice
            if volume.isFinite {
                onVolumeUpdated?(volume)
            }

            volumeIteration = 0
        }

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        guard volume > -48 || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
            return // print("Too quiet, not detecting")
        }

        // Do Note / Onset Detection
        filterbank.calculateMagnitudes(buffer)

        let onsetData = onsetDetection.run(buffer, filterbankMagnitudes: filterbank.magnitudes)
        let chromaVector = chroma(pitchDetection.currentDetectionMode)
        pitchDetection.run(chromaVector)

        performOnMainThread {
            self.onAudioProcessed?(ProcessedAudio(
                audioData: buffer,
                chromaVector: chromaVector,
                filterBandAmplitudes: self.filterbank.magnitudes,
                onsetFeatureValue: onsetData.featureValue,
                onsetThreshold: onsetData.currentThreshold,
                onsetDetected: onsetData.onsetDetected
            ))
        }
    }

    public func setExpectedEvent(_ event: NoteDetectionData) {
        pitchDetection.expectedNoteEvent = event
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
        case .lowPitches:
            return lowChroma
        case .highPitches:
            return highChroma
        case .highAndLow:
            return lowChroma + highChroma
        }
    }
}
