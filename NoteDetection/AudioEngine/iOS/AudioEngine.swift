//
//  AudioEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation
import AVFoundation

public class AudioEngine: AudioEngineProtocol {
    // Array to write audio data for onAudioData callback
    var audioData: [Float] = []

    public var onAudioData: OnAudioDataCallback? {
        didSet { do { try setInputUnitCallback() } catch { print(error.localizedDescription) } }
    }

    public var onSettingsChanged: OnAudioEngineSettingsChangedCallback?

    // If the first init fails, allow users to try again until it works:
    private static var _sharedInstance: AudioEngine?
    public static var sharedInstance: AudioEngine? {
        if _sharedInstance == nil {
            _sharedInstance = try? AudioEngine()
        }

        return _sharedInstance
    }

    // AudioEngine has no public initialisers and is only accessible via `sharedInstance`:
    private init() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try audioSession.overrideOutputAudioPort(.speaker)

        // It's not fatal if these settings fail:
        let preferredSampleRate = 44100.0
        let preferredFrameSliceCount = 1024.0
        try? audioSession.setPreferredSampleRate(preferredSampleRate)

        // The actual settings can differ from our preferred ones:
        let actualSampleRate = audioSession.sampleRate
        try? audioSession.setPreferredIOBufferDuration(preferredFrameSliceCount / actualSampleRate)

        // Create and initialize audio unit for microphone input with actual settings from audioSession
        audioIOUnit = try AudioUnit.createInputUnit(sampleRate: actualSampleRate, numberOfChannels: 1)
        try audioIOUnit.initialize()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: .AVAudioSessionRouteChange,
            object: nil
        )
    }

    @objc func handleRouteChange(routeChangeNotification: NSNotification) {
        let audioSession = AVAudioSession.sharedInstance()

        // Sometimes iOS will set the output port to the phone receiver, force it to speaker if we can
        let audioOutputPortType = audioSession.currentRoute.outputs.first?.portType
        if audioOutputPortType == AVAudioSessionPortBuiltInReceiver {
            try? audioSession.overrideOutputAudioPort(.speaker)
        }

        do {
            // It's very unlikely this will throw, but life goes on if it does:
            try updateSampleRateIfNeeded(audioSession.sampleRate)
        } catch {
            print(error.localizedDescription)
        }
    }

    private func updateSampleRateIfNeeded(_ newSampleRate: Double) throws {
        if audioIOUnit.sampleRate == newSampleRate { return }
        let wasRunning = audioIOUnit.isRunning

        // We have to uninitialize the unit before adjusting its sampleRate
        try stop()
        try audioIOUnit.uninitialize()

        do {
            // Doesn't really matter if this fails, just print the error and move on
            try audioIOUnit.setSampleRate(newSampleRate)
        } catch {
            print(error.localizedDescription)
        }

        try audioIOUnit.initialize()
        if wasRunning { try start() }

        onSettingsChanged?(newSampleRate)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        try? stop()
        try? audioIOUnit?.uninitialize()
        try? audioIOUnit?.dispose()
        audioIOUnit = nil // `dispose` invalidates but doesn't null the pointer
        audioData = []
        onAudioData = nil
    }
}

// MARK: Public controls.
extension AudioEngine {
    public func start() throws {
        try audioIOUnit?.start()
    }

    public func stop() throws {
        try audioIOUnit?.stop()
    }
}


/// RemoteIOAudioUnit, from which we capture audio data and execute `onAudioData`
private var audioIOUnit: AudioUnit!

// MARK: Set onAudioData callback to input unit
extension AudioEngine {
    func setInputUnitCallback() throws {

        let callback: AURenderCallback = { (inRefCon, actionFlags, timestamp, busNumber, frameCount, _) -> OSStatus in
            let audioEngine = unsafeBitCast(inRefCon, to: AudioEngine.self)
            guard let onAudioDataCallback = audioEngine.onAudioData else { return noErr } // abort if no callback set

            do { // Update the size of the audioData array if needed
                let frameCount = Int(frameCount)
                if frameCount != audioEngine.audioData.count {
                   audioEngine.audioData = [Float](repeating: 0, count: frameCount)
                }
            }

            var audioBufferList = AudioBufferList(mNumberBuffers: 1, mBuffers: AudioBuffer(
                mNumberChannels: 1,
                mDataByteSize: frameCount * UInt32(MemoryLayout<Float32>.size),
                mData: &audioEngine.audioData
            ))

            let osStatus = AudioUnitRender(audioIOUnit, actionFlags, timestamp, busNumber, frameCount, &audioBufferList)
            if osStatus != noErr {
                print(osStatus.localizedDescription)
                return osStatus // abort and don't call onAudioData
            }

            onAudioDataCallback(audioEngine.audioData)
            return noErr
        }

        try audioIOUnit?.setProperty(
            kAudioOutputUnitProperty_SetInputCallback,
            kAudioUnitScope_Global,
            .outputBus,
            AURenderCallbackStruct(
                inputProc: callback,
                inputProcRefCon: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            )
        )
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

    func setSampleRate(_ newSampleRate: Double) throws {
        try self.setProperty(kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, .inputBus, newSampleRate)
        try self.setProperty(kAudioUnitProperty_SampleRate, kAudioUnitScope_Input, .outputBus, newSampleRate)
    }
}
