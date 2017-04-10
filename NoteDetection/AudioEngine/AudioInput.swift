//
//  AudioInput.swift
//  NoteDetection
//
//  Created by flowing erik on 10.04.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias AudioDataCallback = (([Float]) -> Void)

protocol AudioInput {
    func set(onAudioData: AudioDataCallback?)
    var sampleRate: Double { get }
}
