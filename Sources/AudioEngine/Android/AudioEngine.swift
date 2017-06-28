final class AudioEngine: AudioInput {

    public var sampleRate: Double {
        print("hardcoded samplerate")
        return 44100
    }

    func set(onAudioData: AudioDataCallback?) {
        print("setting callback not implemented")
    }
}
