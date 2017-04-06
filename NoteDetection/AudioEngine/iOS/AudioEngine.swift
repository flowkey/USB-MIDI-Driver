import AVFoundation

public typealias OnAudioDataCallback = (([Float]) -> Void)
public typealias OnSampleRateChanged = ((_ sampleRate: Double) -> Void)

final class AudioEngine {
    fileprivate var audioData: [Float] = []

    /// RemoteIOAudioUnit, from which we capture audio data and execute `onAudioData`
    fileprivate let audioIOUnit: AudioUnit
    public var onAudioData: OnAudioDataCallback?

    public var sampleRate: Double {
        return AVAudioSession.sharedInstance().sampleRate
    }

    public var onSampleRateChanged: OnSampleRateChanged?

    // AudioEngine has no public initialisers and is only accessible via `sharedInstance`:
    init() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.overrideOutputAudioPort(.speaker)

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

    deinit {
        print("deiniting AudioEngine")
        NotificationCenter.default.removeObserver(self)
        try? stop()
        try? audioIOUnit.uninitialize()
        try? audioIOUnit.dispose()
    }
}

// MARK: Public controls.
extension AudioEngine {
    public func start() throws {
        try audioIOUnit.start()
    }

    public func stop() throws {
        try audioIOUnit.stop()
    }
}

extension AudioEngine {
    @objc func handleRouteChange(routeChangeNotification: NSNotification) {
        let audioSession = AVAudioSession.sharedInstance()

        // Sometimes iOS will set the output port to the phone receiver, force it to speaker if we can
        let audioOutputPortType = audioSession.currentRoute.outputs.first?.portType
        if audioOutputPortType == AVAudioSessionPortBuiltInReceiver {
            try? audioSession.overrideOutputAudioPort(.speaker)
        }

        // It's very unlikely this will throw, life goes on if it does:
        printOnErrorAndContinue { try updateSampleRateIfNeeded(audioSession.sampleRate) }
    }

    private func updateSampleRateIfNeeded(_ newSampleRate: Double) throws {
        if audioIOUnit.sampleRate == newSampleRate { return }
        let wasRunning = audioIOUnit.isRunning

        // We have to uninitialize the unit before adjusting its sampleRate
        try stop()
        try audioIOUnit.uninitialize()

        printOnErrorAndContinue { try audioIOUnit.setSampleRate(newSampleRate) }

        try audioIOUnit.initialize()
        if wasRunning { try start() }

        onSampleRateChanged?(newSampleRate)
    }
}

// MARK: Set onAudioData callback to input unit
extension AudioEngine {
    func setInputUnitCallback() throws {
        try audioIOUnit.setCallback(callbackContext: self) { (ctx, actionFlags, timestamp, busNumber, frameCount, _) in
            let `self` = unsafeBitCast(ctx, to: AudioEngine.self) // override "self" with our hacked C context
            guard let onAudioData = self.onAudioData else { return 1 } // generic error, pauses audio

            do { // Update the size of the audioData array if needed
                let frameCount = Int(frameCount)
                if frameCount != self.audioData.count {
                    self.audioData = [Float](repeating: 0, count: frameCount)
                }
            }

            var bufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(
                mNumberChannels: 1,
                mDataByteSize: frameCount * UInt32(MemoryLayout<Float32>.size),
                mData: &self.audioData // could theoretically cause BAD_ACCESS if `onAudioData` takes a long time
            ))

            let status = AudioUnitRender(self.audioIOUnit, actionFlags, timestamp, busNumber, frameCount, &bufferList)
            if status != noErr {
                print(status.localizedDescription)
                return status // abort and don't call onAudioData
            }

            onAudioData(self.audioData)
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
