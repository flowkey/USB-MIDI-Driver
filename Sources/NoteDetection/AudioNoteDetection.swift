import Dispatch

public protocol ProcessedAudioDelegate: class {
    func onAudioProcessed(_: ProcessedAudio) -> Void
}

public typealias AudioTime = Double

public final class AudioNoteDetector: NoteDetector {
    public weak var delegate: NoteDetectorDelegate?
    public weak var processedAudioDelegate: ProcessedAudioDelegate?
    
    static let maxNoteToOnsetTimeDelta = AudioTime(150)

    var filterbank: Filterbank
    
    // ToDo: both of the following members should be private
    // some tests still use them though, needs to be refactored
    let pitchDetection = PitchDetection(noteRange: .standard)
    let onsetDetection = SpectralFluxOnsetDetection()
    
    private var ignoreUntilDeadline: AudioTime?
    private var lastReceivedAudioTimestamp: AudioTime?
    
    fileprivate func isIgnoring(at timestamp: AudioTime) -> Bool {
        guard let deadline = ignoreUntilDeadline else { return false }
        return (timestamp - deadline) < 0
    }

    public func ignoreFor(ms duration: Double) {
        guard let lastReceivedAudioTimeStamp = self.lastReceivedAudioTimestamp
        else { return }
        ignoreUntilDeadline = lastReceivedAudioTimeStamp + duration
    }

    private var audioBuffer: [Float]

    public init(sampleRate: Double) {
        audioBuffer = [Float]()
        audioBuffer.reserveCapacity(1024)

        filterbank = Filterbank(noteRange: pitchDetection.noteRange, sampleRate: sampleRate)
        pitchDetection.onPitchDetected = { [unowned self] timestamp in
            self.onPitchDetected(timestamp: timestamp)
        }
        onsetDetection.onOnsetDetected = { [unowned self] timestamp in
            self.onOnsetDetected(timestamp: timestamp)
        }
    }

    public func set(sampleRate: Double) {
        filterbank = Filterbank(noteRange: pitchDetection.noteRange, sampleRate: sampleRate)
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

    public func process(audio samples: [Float], at timestampMs: AudioTime) {
        self.lastReceivedAudioTimestamp = timestampMs
        // ensure we always have at least 960 samples before processing audio:
        self.audioBuffer.append(contentsOf: samples)
        guard self.audioBuffer.count >= 960 else { return }
        defer { self.audioBuffer.removeAll(keepingCapacity: true) }

        let volume = calculateVolume(from: self.audioBuffer)

        // Volume drops a lot more quickly than the filterbank magnitudes
        // So check we either have enough volume, OR the filterbank is still "ringing out":
        #if os(iOS) // Android has a lot of different microphones with different sensitivities, so don't do it for Android
        guard volume > volumeLowerThreshold || filterbank.magnitudes.contains(where: { $0 > 0.0003 }) else {
            return // print("Too quiet, not detecting")
        }
        #endif

        let filterbankMagnitudes = filterbank.calculateMagnitudes(self.audioBuffer)
        let (onsetData, pitchData) = performNoteDetection(filterbankMagnitudes: filterbankMagnitudes, at: timestampMs)

        // Don't make unnecessary calls to the main thread if there is no delegate:
        guard let processedAudioDelegate = processedAudioDelegate else { return }
        let audioBuffer = self.audioBuffer // make a copy before the buffer is emptied

        DispatchQueue.main.async {
            processedAudioDelegate.onAudioProcessed(
                (audioBuffer, pitchData?.detectedChroma, filterbankMagnitudes, onsetData.featureValue, onsetData.threshold, onsetData.onsetDetected)
            )
        }
    }

    @discardableResult
    public func performNoteDetection(filterbankMagnitudes: [Float], at timestampMs: AudioTime) ->
        (OnsetDetectionResult, PitchDetectionResult?)
    {
        self.lastReceivedAudioTimestamp = timestampMs
        pitchDetection.setExpectedEvent(delegate?.expectedNoteEvent)

        let onsetData = onsetDetection.run(on: filterbankMagnitudes, at: timestampMs)
        let pitchData = pitchDetection.run(on: filterbankMagnitudes, at: timestampMs)
        return (onsetData, pitchData)
    }

    private var lastOnsetTimestamp: AudioTime?
    private var lastNoteTimestamp: AudioTime?

    func onOnsetDetected(timestamp: AudioTime) {
        lastOnsetTimestamp = timestamp
        onInputReceived()
    }

    func onPitchDetected(timestamp: AudioTime) {
        lastNoteTimestamp = timestamp
        onInputReceived()
    }

    func onInputReceived() {
        guard
            let onsetTimestamp = lastOnsetTimestamp,
            let noteTimestamp = lastNoteTimestamp,
            noteTimestamp.isCloseEnough(to: onsetTimestamp)
        else {
            return
        }
        
        let noteEventDetectedTimestamp = max(onsetTimestamp, noteTimestamp)
        lastOnsetTimestamp = nil
        lastNoteTimestamp = nil
        
        if !self.isIgnoring(at: noteEventDetectedTimestamp) {
            guard let delegate = self.delegate else {
                assertionFailure("An event was detected, but the delegate was nil")
                return
            }

            guard let noteEvent = delegate.expectedNoteEvent else {
                print("An event was detected, but the delegate's event is null.")
                return
            }

            DispatchQueue.main.async {
                delegate.onNoteEventDetected(
                    noteDetector: self,
                    timestamp: noteEventDetectedTimestamp,
                    detectedEvent: noteEvent
                )
            }
        }
    }
}

extension AudioTime {
    func isCloseEnough(to otherAudioTime: AudioTime) -> Bool {
        let timestampDiff = abs(self - otherAudioTime)
        return timestampDiff < AudioNoteDetector.maxNoteToOnsetTimeDelta
    }
}
