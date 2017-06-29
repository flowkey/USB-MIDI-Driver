import CAndroidAudioEngine

final class AudioEngine: AudioInput {

    private var onAudioData: AudioDataCallback?

    public var onSampleRateChanged: SampleRateChangedCallback?

    public init() {
        CAndroidAudioEngine.initialize(44100, 512)
    }

    public var sampleRate: Double {
        return Double(CAndroidAudioEngine.getSamplerate())
    }

    func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
        CAndroidAudioEngine.setOnAudioData({ buffer, count, context in
            let `self` = unsafeBitCast(context, to: AudioEngine.self) // override "self" with our hacked C context
            let bufferPointer = UnsafeBufferPointer(start: buffer, count: Int(count))
            let floatArray = [Float](bufferPointer)
            self.onAudioData?(floatArray)
        }, Unmanaged.passUnretained(self).toOpaque())
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
