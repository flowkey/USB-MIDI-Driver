//
//  AudioEngine.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias OnAudioDataCallback = (([Float32]) -> Void)
public typealias OnAudioEngineSettingsChangedCallback = ((_ sampleRate: Double) -> Void)

public protocol AudioEngineProtocol {
    var onAudioData: OnAudioDataCallback? { get set }
    var onSettingsChanged: OnAudioEngineSettingsChangedCallback? { get set }

    func start() throws
    func stop() throws
}
