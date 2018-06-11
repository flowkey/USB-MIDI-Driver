import CAndroidAudioEngine
import JNI

public final class AudioEngine: AudioEngineProtocol {
    private var onAudioData: AudioDataCallback?
    public var onSampleRateChanged: SampleRateChangedCallback?
    public var sampleRate: Double
    private let bufferSize: Int

    public init() throws { // throws as in iOS
        AndroidPermissions.sharedInstance = AndroidPermissions()

        do {
            let audioSettingsClass = getAudioSettingsJavaClass()
            let jContext = try getMainActivityContext()
            sampleRate = try jni.callStatic("getFastAudioPathSampleRate", on: audioSettingsClass, arguments: [jContext])
            bufferSize = try jni.callStatic("getFastAudioPathBufferSize", on: audioSettingsClass, arguments: [jContext])
        } catch {
            assertionFailure("Couldn't get either the settings class or optimal sample rates")
            sampleRate = 48000 // most common fast audio path sampleRate
            bufferSize = 512 // as in our settings for iOS
        }
    }

    deinit {
        CAndroidAudioEngine_deinitialize()
        AndroidPermissions.sharedInstance = nil
    }

    public func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
        CAndroidAudioEngine_setOnAudioData({ buffer, count, sampleRate, context in
            guard let pointerToContext = context else { return }
            let `self` = Unmanaged<AudioEngine>.fromOpaque(pointerToContext).takeUnretainedValue()
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

private func getAudioSettingsJavaClass() -> JavaClass {
    let audioSettingsClassName = "com/flowkey/notedetection/Audio/SettingsKt"
    guard let jAudioSettingsClass = try? jni.FindClass(name: audioSettingsClassName) else {
        fatalError("Could not find Audio Settings class")
    }
    return jAudioSettingsClass
}

// MARK: Public controls.
extension AudioEngine {
    public func startMicrophone() throws {
        if CAndroidAudioEngine_isInitialized() {
            CAndroidAudioEngine_start()
        } else {
            guard let permissions = AndroidPermissions.sharedInstance else {
                assertionFailure("Permissions shared instance doesn't exist.")
                return
            }
            try permissions.requestAudioPermissionIfRequired { [weak self] result in
                guard 
                    let `self` = self,
                    result == .granted 
                else { 
                    assertionFailure("Permission was not granted!")
                    return
                }
                let bufferSize = Int32(self.bufferSize)
                let sampleRate = Int32(self.sampleRate)
                CAndroidAudioEngine_initialize(sampleRate, bufferSize)
                CAndroidAudioEngine_start()
            }
        }
    }

    public func stopMicrophone() {
        CAndroidAudioEngine_stop()
    }
}


/// MARK: debug prints for devices audio settings
private func printAudioSettings(sampleRate: Double, bufferSize: Int) {
    let audioSettingsClass = getAudioSettingsJavaClass()
    let jContext = try! getMainActivityContext()
    let hasLowLatencyFeature: Bool = try! jni.callStatic("hasLowLatencyFeature", on: audioSettingsClass, arguments: [jContext])
    let hasProAudioFeature: Bool = try! jni.callStatic("hasProAudioFeature", on: audioSettingsClass, arguments: [jContext])
    printAudioSettings(sampleRate: sampleRate, bufferSize: bufferSize, lowLatency: hasLowLatencyFeature, proAudio: hasProAudioFeature)
}
private func printAudioSettings(sampleRate: Double, bufferSize: Int, lowLatency: Bool, proAudio: Bool) {
    print("-------------------- Audio Settings ----------------------------")
    print("sampleRate: " + String(describing: sampleRate))
    print("bufferSize: " + String(describing: bufferSize))
    print("hasLowLatency: " + String(describing: lowLatency))
    print("hasProAudio: " + String(describing: proAudio))
    print("----------------------------------------------------------------")
}
