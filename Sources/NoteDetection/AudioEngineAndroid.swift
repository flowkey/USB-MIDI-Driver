import CAndroidAudioEngine

final class AudioEngine: AudioInput {
    private var onAudioData: AudioDataCallback?
    fileprivate let androidPermissions = AndroidPermissions()

    public var onSampleRateChanged: SampleRateChangedCallback? {
        didSet {
            CAndroidAudioEngine_setOnSamplerateChange({ sampleRate, context in
                let `self` = unsafeBitCast(context, to: AudioEngine.self)
                self.onSampleRateChanged?(Double(sampleRate))
            }, Unmanaged.passUnretained(self).toOpaque())
        }
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
    public func start() throws {
        if CAndroidAudioEngine_isInitialized() {
            CAndroidAudioEngine_start()
        } else {
            try androidPermissions.requestAudioPermissionIfRequired { result in
                guard result == .granted else { assertionFailure("Permission was not granted!"); return }
                CAndroidAudioEngine_initialize(44100, 1024)
            }
        }
    }

    public func stop() {
        CAndroidAudioEngine_stop()
    }
}
