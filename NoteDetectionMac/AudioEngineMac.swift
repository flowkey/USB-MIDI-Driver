//
//  AudioEngineMac.swift
//  NoteDetection
//
//  Created by Geordie Jay on 04.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation

final class AudioEngine: AudioInput {
    var sampleRate: Double = 44100
    var onSampleRateChanged: SampleRateChangedCallback?
    func set(onAudioData: AudioDataCallback?) {}

    func start() throws {}
    func stop() throws {}
}
