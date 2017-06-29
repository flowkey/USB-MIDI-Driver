import CAndroidAudioEngine

final class AudioEngine: AudioInput {

    public var onSampleRateChanged: SampleRateChangedCallback?

    public init() {
        CAndroidAudioEngine.initialize()
    }

    public var sampleRate: Double {
        return Double(CAndroidAudioEngine.getSampleRate())
    }

    func set(onAudioData: AudioDataCallback?) {
        print("setting callback not implemented")
    }
}


// MARK: Public controls.
extension AudioEngine {
    public func start() {
        CAndroidAudioEngine.start()
    }

    public func stop() {
        CAndroidAudioEngine.stop()
    }
}