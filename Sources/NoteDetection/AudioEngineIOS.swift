import AVFoundation

public final class AudioEngine: AudioEngineProtocol {
    fileprivate var audioData: [Float] = []

    /// RemoteIOAudioUnit, from which we capture audio data and execute `onAudioData`
    fileprivate let audioIOUnit: AudioUnit
    fileprivate var onAudioData: AudioDataCallback?

    public var sampleRate: Double {
        return AVAudioSession.sharedInstance().sampleRate
    }

    public var onSampleRateChanged: SampleRateChangedCallback?

    public init() throws {
        let audioSession = AVAudioSession.sharedInstance()

        try? audioSession.setCategoryToPlayAndRecordIfNecessary()

        // It's not fatal if these settings fail:
        let preferredSampleRate = 44100.0
        try? audioSession.setPreferredSampleRate(preferredSampleRate)

        // The actual settings can differ from our preferred ones:
        let preferredFrameSliceCount = 1024.0
        let actualSampleRate = audioSession.sampleRate
        try? audioSession.setPreferredIOBufferDuration(preferredFrameSliceCount / actualSampleRate)

        // Create and initialize audio unit for microphone input with actual settings from audioSession
        audioIOUnit = try AudioUnit.createInputUnit(sampleRate: actualSampleRate, numberOfChannels: 1)
        try audioIOUnit.initialize()
        try setInputUnitCallback()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: .AVAudioSessionRouteChange,
            object: nil
        )
    }

    public func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
    }

    func enableInput() throws {
        try audioIOUnit.uninitialize()
        try audioIOUnit.setProperty(kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, .inputBus, UInt32(truncating: true))
        try audioIOUnit.initialize()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        try? stopMicrophone()
        try? audioIOUnit.uninitialize()
        try? audioIOUnit.dispose()
    }
}

// MARK: Public controls.
extension AudioEngine {
    public func startMicrophone() throws {
        if !inputIsEnabled { try? enableInput() }
        try updateSampleRateIfNeeded(self.sampleRate)
        try audioIOUnit.start()
    }

    var inputIsEnabled: Bool {
        // check, default to false
        let result: UInt32? =
            audioIOUnit.getProperty(kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, .inputBus) ?? 0

        return result == 1
    }

    public func stopMicrophone() throws {
        try audioIOUnit.stop()
    }
}

extension AudioEngine {
    @objc func handleRouteChange(routeChangeNotification: NSNotification) {
        let audioSession = AVAudioSession.sharedInstance()

        // Sometimes iOS will set the output port to the phone receiver (even when using .defaultToSpeaker),
        // override it to speaker if it's set to receiver
        let audioOutputPortType = audioSession.currentRoute.outputs.first?.portType
        if audioOutputPortType == AVAudioSessionPortBuiltInReceiver {
            try? audioSession.overrideOutputAudioPort(.speaker)
        }

        // It's very unlikely this will throw, life goes on if it does:
        printOnErrorAndContinue { try updateSampleRateIfNeeded(audioSession.sampleRate) }
    }

    fileprivate func updateSampleRateIfNeeded(_ newSampleRate: Double) throws {
        if audioIOUnit.sampleRate == newSampleRate { return }
        let wasRunning = audioIOUnit.isRunning

        // We have to uninitialize the unit before adjusting its sampleRate
        try stopMicrophone()
        try audioIOUnit.uninitialize()

        printOnErrorAndContinue { try audioIOUnit.setSampleRate(newSampleRate) }

        try audioIOUnit.initialize()
        if wasRunning { try startMicrophone() }

        onSampleRateChanged?(newSampleRate)
    }
}

// MARK: Set onAudioData callback to input unit
extension AudioEngine {
    func setInputUnitCallback() throws {
        try audioIOUnit.setCallback(callbackContext: self) { (ctx, actionFlags, timestamp, busNumber, frameCount, _) in
            let `self` = Unmanaged<AudioEngine>.fromOpaque(ctx).takeUnretainedValue()
            guard let onAudioData = self.onAudioData else { return 1 } // generic error, pauses audio

            do { // Update the size of the audioData array if needed
                let frameCount = Int(frameCount)
                if frameCount != self.audioData.count {
                    self.audioData = [Float](repeating: 0, count: frameCount)
                }
            }

            // encapsulate our audioData array in a bufferList in order to use AudioUnitRender()
            var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(
                mNumberChannels: 1,
                mDataByteSize: frameCount * UInt32(MemoryLayout<Float32>.size),
                mData: &self.audioData // could theoretically cause BAD_ACCESS if `onAudioData` takes a long time
            ))

            // render audio unit output (mic data) into the bufferList / audioData
            let status = AudioUnitRender(self.audioIOUnit, actionFlags, timestamp, busNumber, frameCount, &bufferList)
            if status != noErr {
                print(status.localizedDescription)
                return status // abort and don't call onAudioData
            }

            let audioTimeStamp = timestamp.pointee
            if !audioTimeStamp.mFlags.contains(AudioTimeStampFlags.hostTimeValid) {
                assertionFailure("hosttime is not valid")
            }
            let timestampInMs: AudioTime = Double(audioTimeStamp.mHostTime) * hostTimeToMillisFactor
            onAudioData(self.audioData, timestampInMs)

            return noErr
        }
    }
}

// These only apply to our `audioIOUnit`, so separate them from the more general AudioUnit extensions
private extension AudioUnit {
    var isRunning: Bool {
        return getProperty(kAudioOutputUnitProperty_IsRunning, kAudioUnitScope_Global, .outputBus) ?? false
    }

    var sampleRate: Double? {
        return getProperty(kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, .inputBus)
    }

    func setCallback(callbackContext context: AnyObject, callback: @escaping AURenderCallback) throws {
        try setProperty(
            kAudioOutputUnitProperty_SetInputCallback,
            kAudioUnitScope_Global,
            .outputBus,
            AURenderCallbackStruct(inputProc: callback, inputProcRefCon: Unmanaged.passUnretained(context).toOpaque())
        )
    }

    func setSampleRate(_ newSampleRate: Double) throws {
        try self.setProperty(kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, .inputBus, newSampleRate)
        try self.setProperty(kAudioUnitProperty_SampleRate, kAudioUnitScope_Input, .outputBus, newSampleRate)
    }
}

/// Call a function that can throw and just print the error if one occurs. Used for functions where we
/// want to know that they failed in debug, but don't want to interrupt program flow.
private func printOnErrorAndContinue(_ function: () throws -> Void) {
    do { try function() } catch { print(error.localizedDescription) }
}

// taken from https://stackoverflow.com/questions/675626/coreaudio-audiotimestamp-mhosttime-clock-frequency
private let hostTimeToMillisFactor: Double = {
    var timebaseInfo = mach_timebase_info_data_t(numer: 1, denom: 1)
    
    if mach_timebase_info(&timebaseInfo) != KERN_SUCCESS {
        assertionFailure("Could not get timebase info")
    }
    
    let hostTimeToNanosFactor: Double = Double(timebaseInfo.numer) / Double(timebaseInfo.denom)
    
    return hostTimeToNanosFactor / 1_000_000
}()
