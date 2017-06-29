import CAndroidAudioEngine

final class AudioEngine: AudioInput {

    private var onAudioData: AudioDataCallback?

    public var onSampleRateChanged: SampleRateChangedCallback? {
        didSet {
            CAndroidAudioEngine_setOnSamplerateChange({ sampleRate, context in
                let `self` = unsafeBitCast(context, to: AudioEngine.self)
                self.onSampleRateChanged?(Double(sampleRate))
            }, Unmanaged.passUnretained(self).toOpaque())
        }
    }

    public init() {
        CAndroidAudioEngine_initialize(44100, 1024)
    }

    public var sampleRate: Double {
        return Double(CAndroidAudioEngine_getSamplerate())
    }

    func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
        CAndroidAudioEngine_setOnAudioData({ buffer, count, context in
            let `self` = unsafeBitCast(context, to: AudioEngine.self)
            let bufferPointer = UnsafeBufferPointer(start: buffer, count: Int(count))
            let floatArray = [Float](bufferPointer)
            self.onAudioData?(floatArray)
        }, Unmanaged.passUnretained(self).toOpaque())
    }
}


// MARK: Public controls.
extension AudioEngine {
    public func start() {
        CAndroidAudioEngine_start()
    }

    public func stop() {
        CAndroidAudioEngine_stop()
    }
}
