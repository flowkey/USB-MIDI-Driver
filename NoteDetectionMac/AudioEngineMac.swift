//
//  AudioEngineMac.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

final class AudioEngine: SuperpoweredOSXAudioIODelegate {
    enum Error: Swift.Error { case couldNotStartEngine }

    private var onAudioData: AudioDataCallback?
    private var superpowered: SuperpoweredOSXAudioIO!

    init() {
        self.superpowered = SuperpoweredOSXAudioIO(delegate: self, preferredBufferSizeMs: 12, numberOfChannels: 1, enableInput: true, enableOutput: true)
    }

    var sampleRate: Double = 44100
    var onSampleRateChanged: SampleRateChangedCallback?
    func set(onAudioData: AudioDataCallback?) {
        self.onAudioData = onAudioData
    }

    func start() throws {
        let result = superpowered.start()
        if !result {
            throw Error.couldNotStartEngine
        }
    }

    func stop() throws {
        superpowered.stop()
    }

    func audioProcessingCallback(_ inputBuffers: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, inputChannels: UInt32, outputBuffers: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, outputChannels: UInt32, numberOfSamples: UInt32, samplerate sampleRate: UInt32, hostTime: UInt64) -> Bool {

        let sampleRate = Double(sampleRate)
        if self.sampleRate != sampleRate {
            self.sampleRate = sampleRate
            onSampleRateChanged?(sampleRate)
        }

        let bufferPointer = UnsafeBufferPointer(start: inputBuffers.pointee, count: Int(numberOfSamples))
        let floatArray = [Float](bufferPointer)
        self.onAudioData?(floatArray)

        return false // silence audio output
    }
}
