//
//  AudioEngineMac.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public final class AudioEngine: SuperpoweredOSXAudioIODelegate, AudioEngineProtocol {
    enum Error: Swift.Error { case couldNotStartEngine }

    private var onAudioData: AudioDataCallback?
    private var superpowered: SuperpoweredOSXAudioIO!

    public init() throws {
        self.superpowered = SuperpoweredOSXAudioIO(delegate: self, preferredBufferSizeMs: 12, numberOfChannels: 1, enableInput: true, enableOutput: true)
    }

    public var sampleRate: Double = 44100
    public var onSampleRateChanged: SampleRateChangedCallback?
    public func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
    }

    public func startMicrophone() throws {
        let result = superpowered.start()
        if !result {
            throw Error.couldNotStartEngine
        }
    }

    public func stopMicrophone() throws {
        superpowered.stop()
    }

    public func audioProcessingCallback(_ inputBuffers: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, inputChannels: UInt32, outputBuffers: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, outputChannels: UInt32, numberOfSamples: UInt32, samplerate sampleRate: UInt32, hostTime: UInt64) -> Bool {

        let sampleRate = Double(sampleRate)
        if self.sampleRate != sampleRate {
            self.sampleRate = sampleRate
            onSampleRateChanged?(sampleRate)
        }

        let bufferPointer = UnsafeBufferPointer(start: inputBuffers.pointee, count: Int(numberOfSamples))
        let floatArray = [Float](bufferPointer)
        self.onAudioData?(floatArray, Double(hostTime) / 1_000_000)

        return false // silence audio output
    }
}
