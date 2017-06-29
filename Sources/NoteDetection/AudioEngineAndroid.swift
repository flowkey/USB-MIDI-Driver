import CAndroidAudioEngine

final class AudioEngine: AudioInput {

    public var onSampleRateChanged: SampleRateChangedCallback?

    public var sampleRate: Double {
        return Double(getSampleRateFromAudioEngine())
    }

    func set(onAudioData: AudioDataCallback?) {
        print("setting callback not implemented")
    }
}


// MARK: Public controls.
extension AudioEngine {
    public func start() throws {

    }

    public func stop() throws {

    }
}