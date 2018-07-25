import Dispatch

// Chroma extractors for our different ranges:
private let lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
private let highRange = lowRange.last! ... MIDINumber(note: .d, octave: 8)


public protocol ProcessedAudioDelegate: class {
    func onAudioProcessed(_: ProcessedAudio) -> Void
}

public final class AudioNoteDetector: NoteDetector {
    public weak var delegate: NoteDetectorDelegate?
    public weak var processedAudioDelegate: ProcessedAudioDelegate?
    
    static let maxNoteToOnsetTimeDelta = Timestamp(150)
    
    public var expectedNoteEvent: DetectableNoteEvent? {
        didSet { pitchDetection.setExpectedEvent(expectedNoteEvent) }
    }

    let filterbank: FilterBank
    let pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!)
    let onsetDetection = SpectralFluxOnsetDetection()
    
    fileprivate var ignoreUntilDeadline: Timestamp?
    
    fileprivate func isIgnoring(at timestamp: Timestamp) -> Bool {
        guard let deadline = ignoreUntilDeadline else { return false }
        return (timestamp - deadline) < 0
    }

    public func ignoreFor(ms duration: Double) {
        ignoreUntilDeadline = .now + duration
    }

    private var audioBuffer: [Float]

    public init(sampleRate: Double) {
        audioBuffer = [Float]()
        audioBuffer.reserveCapacity(1024)

        filterbank = FilterBank(lowRange: lowRange, highRange: highRange, sampleRate: sampleRate)
        pitchDetection.onPitchDetected = { [unowned self] timestamp in
            self.onPitchDetected(timestamp: timestamp)
        }
        onsetDetection.onOnsetDetected = { [unowned self] timestamp in
            self.onOnsetDetected(timestamp: timestamp)
        }
    }


    /// The volume level above which the pitch detection is activated and reported volume increases above 0.
    /// In reality our noise floor is closer to -96dB, but this value seems to work well not only save power
    /// but also to show a reasonable range of volume for our application.
    let volumeLowerThreshold: Float = -48

    var volumeIteration = 0
    private func calculateVolume(from buffer: [Float]) -> Float {
        let volume = linearToDecibel(rootMeanSquare(buffer))

        volumeIteration += 1
        
        if
            volumeIteration >= 3, // avoid overloading the main thread unnecessarily
            let delegate = delegate,
            volume.isFinite
        {
            // wanna calculate dBFS reference value? this could be helpful https://goo.gl/rzCeAW
            let ratio = 1 - (volume / volumeLowerThreshold)
            let ratioBetween0and1 = min(max(0, ratio), 1)
            DispatchQueue.main.async {
                delegate.onInputLevelChanged(ratio: ratioBetween0and1)
            }
            volumeIteration = 0
        }

        return volume
    }

    public func process(audio samples: [Float]) {
        audioBuffer.append(contentsOf: samples)
        if audioBuffer.count >= 960 {
            performNoteDetection(audioBuffer)
            audioBuffer.removeAll(keepingCapacity: true)
        }
    }

    private func performNoteDetection(_ audioData: [Float]) {
        let volume = calculateVolume(from: audioData)

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        #if os(iOS) // Android has a lot of different microphones with different sensitivities, so don't do it for Android
        guard volume > volumeLowerThreshold || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
            return // print("Too quiet, not detecting")
        }
        #endif

        // Do Pitch / Onset Detection
        filterbank.calculateMagnitudes(audioData)
        let onsetData = onsetDetection.run(inputData: filterbank.magnitudes)
        let chromaVector = filterbank.getChroma(for: pitchDetection.currentDetectionMode)
        pitchDetection.run(chromaVector)

        
        // Don't make unnecessary calls to the main thread if there is no delegate:
        guard let processedAudioDelegate = processedAudioDelegate else {
            return
        }
        
        DispatchQueue.main.async {
            processedAudioDelegate.onAudioProcessed(
                (audioData, chromaVector, self.filterbank.magnitudes, onsetData.featureValue, onsetData.threshold, onsetData.onsetDetected)
            )
        }
    }

    private var lastOnsetTimestamp: Timestamp?
    private var lastNoteTimestamp: Timestamp?

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
            let noteEventDetectedTimestamp = Timestamp.now
            self.lastOnsetTimestamp = nil
            self.lastNoteTimestamp = nil
            
            if !self.isIgnoring(at: noteEventDetectedTimestamp) {
                DispatchQueue.main.async {
                    self.delegate?.onNoteEventDetected(noteDetector: self, timestamp: noteEventDetectedTimestamp)
                }
            }
        }
    }

    private func timestampsAreCloseEnough() -> Bool {
        guard
            let onsetTimestamp = lastOnsetTimestamp,
            let noteTimestamp = lastNoteTimestamp
            else { return false }

        let timestampDiff = abs(onsetTimestamp - noteTimestamp)
        return timestampDiff < AudioNoteDetector.maxNoteToOnsetTimeDelta
    }
}
