//
//  AudioInput.swift
//  NoteDetection
//
//  Created by flowing erik on 10.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias AudioDataCallback = (([Float]) -> Void)

protocol AudioInput: class {
    var sampleRate: Double { get }
    var onSampleRateChanged: SampleRateChangedCallback? { get set }

    func start() throws
    func stop() throws

    func set(onAudioData: AudioDataCallback?)
}
