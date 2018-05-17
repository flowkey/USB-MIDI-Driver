import Dispatch
import UIKit

public typealias NoteEventDetectedCallback = (Timestamp) -> Void

// Chroma extractors for our different ranges:
private let lowRange = MIDINumber(note: .g, octave: 1) ... MIDINumber(note: .d, octave: 5)
private let highRange = lowRange.last! ... MIDINumber(note: .d, octave: 8)

final class AudioNoteDetector: NoteDetector {
    static let maxNoteToOnsetTimeDelta = Timestamp(150)

    var expectedNoteEvent: DetectableNoteEvent? {
        didSet { pitchDetection.setExpectedEvent(expectedNoteEvent) }
    }

    let filterbank: FilterBank
    let pitchDetection = PitchDetection(lowNoteBoundary: lowRange.last!)
    let onsetDetection = SpectralFluxOnsetDetection()

    var onInputLevelChanged: InputLevelChangedCallback?
    var onAudioProcessed: AudioProcessedCallback?

    private var audioBuffer: [Float]

    init(sampleRate: Double) {
        audioBuffer = [Float]()
        audioBuffer.reserveCapacity(1024)

        filterbank = FilterBank(lowRange: lowRange, highRange: highRange, sampleRate: sampleRate)
        pitchDetection.onPitchDetected = { [unowned self] timestamp in
            self.onPitchDetected()
        }
        onsetDetection.onOnsetDetected = { [unowned self] timestamp in
            self.onOnsetDetected()
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
        if volumeIteration >= 3 { // avoid overloading the main thread unnecessarily
            if let onInputLevelChanged = onInputLevelChanged, volume.isFinite {
                // wanna calculate dBFS reference value? this could be helpful https://goo.gl/rzCeAW
                let ratio = 1 - (volume / volumeLowerThreshold)
                let ratioBetween0and1 = min(max(0, ratio), 1)
                DispatchQueue.main.async { 
                    onInputLevelChanged(ratioBetween0and1) 
                }
            }
          volumeIteration = 0
        }

        return volume
    }

    func process(audio samples: [Float]) {
        print("incoming samples: ", samples.count)
        audioBuffer.append(contentsOf: samples)
        if audioBuffer.count >= 960 {
            print("perform note detection with ", audioBuffer.count)
            performNoteDetection(audioBuffer)
            audioBuffer.removeAll(keepingCapacity: true)
        }
        print("audioBuffer count: ", audioBuffer.count)
        print("audioBuffer capacity: ", audioBuffer.capacity)
        print("-------------------")
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

        // Don't make unnecessary calls to the main thread if there is no callback set:
        if let onAudioProcessed = onAudioProcessed {
            let filterbankMagnitudes = self.filterbank.magnitudes
            DispatchQueue.main.async {
                onAudioProcessed(
                    (audioData, chromaVector, filterbankMagnitudes, onsetData.featureValue, onsetData.threshold, onsetData.onsetDetected)
                )
            }
        }
    }

    private var lastOnsetTimestamp: Timestamp?
    private var lastNoteTimestamp: Timestamp?

    var onNoteEventDetected: NoteEventDetectedCallback?

    func onOnsetDetected(timestamp: Timestamp = .now) {
        lastOnsetTimestamp = timestamp
        onInputReceived()
    }

    func onPitchDetected(timestamp: Timestamp = .now) {
        lastNoteTimestamp = timestamp
        onInputReceived()
    }

    func onInputReceived() {
        if timestampsAreCloseEnough() {
            self.lastOnsetTimestamp = nil
            self.lastNoteTimestamp = nil
            
            DispatchQueue.main.async {
                self.onNoteEventDetected?(.now)
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
