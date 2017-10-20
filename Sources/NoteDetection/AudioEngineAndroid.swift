import CAndroidAudioEngine

final class AudioEngine: AudioInput {
    private var onAudioData: AudioDataCallback?
    public var onSampleRateChanged: SampleRateChangedCallback?
    public var sampleRate: Double = 44100

    init() throws { // throws as in iOS
        AndroidPermissions.sharedInstance = AndroidPermissions()
    }

    deinit {
        AndroidPermissions.sharedInstance = nil
    }

    func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
        CAndroidAudioEngine_setOnAudioData({ buffer, count, sampleRate, context in
            let `self` = unsafeBitCast(context, to: AudioEngine.self)
            let bufferPointer = UnsafeBufferPointer(start: buffer, count: Int(count))
            let floatArray = [Float](bufferPointer)
            let sr = Double(sampleRate)
            if sr != self.sampleRate {
                self.onSampleRateChanged?(sr)
            }
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
            guard let permissions = AndroidPermissions.sharedInstance else {
                assertionFailure("Permissions shared instance doesn't exist.")
                return
            }
            try permissions.requestAudioPermissionIfRequired { result in
                guard result == .granted else { assertionFailure("Permission was not granted!"); return }
                CAndroidAudioEngine_initialize(Int32(self.sampleRate), 1024)
                CAndroidAudioEngine_start()
            }
        }
    }

    public func stop() {
        CAndroidAudioEngine_stop()
    }
}
