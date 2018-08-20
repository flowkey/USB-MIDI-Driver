import Dispatch

// Chroma extractors for our different ranges:
private let noteRange = NoteRange(
    fullRange: MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 8),
    lowNoteBoundary: MIDINumber(note: .d, octave: 5)
)

public protocol ProcessedAudioDelegate: class {
    func onAudioProcessed(_: ProcessedAudio) -> Void
}

public final class AudioNoteDetector: NoteDetector {
    public weak var delegate: NoteDetectorDelegate?
    public weak var processedAudioDelegate: ProcessedAudioDelegate?
    
    static let maxNoteToOnsetTimeDelta = Timestamp(150)

    var filterbank: FilterBank
    let pitchDetection = PitchDetection(noteRange: noteRange)
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

        filterbank = FilterBank(noteRange: noteRange, sampleRate: sampleRate)
        pitchDetection.onPitchDetected = { [unowned self] timestamp in
            self.onPitchDetected(timestamp: timestamp)
        }
        onsetDetection.onOnsetDetected = { [unowned self] timestamp in
            self.onOnsetDetected(timestamp: timestamp)
        }
    }

    public func set(sampleRate: Double) {
        filterbank = FilterBank(noteRange: noteRange, sampleRate: sampleRate)
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

    public func process(audio samples: [Float], at timestampMs: Timestamp) {
        audioBuffer.append(contentsOf: samples)
        if audioBuffer.count >= 960 {
            performNoteDetection(audioData: audioBuffer, at: timestampMs)
            audioBuffer.removeAll(keepingCapacity: true)
        }
    }

    private func performNoteDetection(audioData: [Float], at timestampMs: Timestamp) {
        let volume = calculateVolume(from: audioData)

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        #if os(iOS) // Android has a lot of different microphones with different sensitivities, so don't do it for Android
        guard volume > volumeLowerThreshold || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
            return // print("Too quiet, not detecting")
        }
        #endif

        let filterbankMagnitudes = filterbank.calculateMagnitudes(audioData)
        performNoteDetection(filterbankMagnitudes: filterbankMagnitudes, at: timestampMs)
    }

    private func performNoteDetection(filterbankMagnitudes: [Float], at timestampMs: Timestamp) {
        pitchDetection.setExpectedEvent(delegate?.expectedNoteEvent)

        // Do Pitch / Onset Detection
        let onsetData = onsetDetection.run(on: filterbankMagnitudes, at: timestampMs)
        let pitchData = pitchDetection.run(on: filterbankMagnitudes, at: timestampMs)

        // Don't make unnecessary calls to the main thread if there is no delegate:
        guard let processedAudioDelegate = processedAudioDelegate else {
            return
        }
        
        DispatchQueue.main.async {
            processedAudioDelegate.onAudioProcessed(
                (pitchData?.detectedChroma, filterbankMagnitudes, onsetData.featureValue, onsetData.threshold, onsetData.onsetDetected)
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
            lastOnsetTimestamp = nil
            lastNoteTimestamp = nil
            
            if !self.isIgnoring(at: noteEventDetectedTimestamp) {
                guard let noteEvent = self.delegate?.expectedNoteEvent else {
                    assertionFailure("an event was detected, but the delegates event is null.")
                    return
                }
                DispatchQueue.main.async {
                    self.delegate?.onNoteEventDetected(
                        noteDetector: self,
                        timestamp: noteEventDetectedTimestamp,
                        detectedEvent: noteEvent
                    )
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
