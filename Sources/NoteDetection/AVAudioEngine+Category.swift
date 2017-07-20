//
//  AVAudioEngine+Category.swift
//  NoteDetection
//
//  Created by flowing erik on 11.07.17.
//  Copyright © 2017 flowkey. All rights reserved.
//
import AVFoundation

extension AVAudioSession {
    func setCategoryToPlayAndRecordIfNecessary() throws {
        if category != AVAudioSessionCategoryPlayAndRecord {
            try setActive(false)
            var options: AVAudioSessionCategoryOptions = [.defaultToSpeaker, .allowBluetooth]
            if #available(iOS 10.0, *) {
                options.insert([.allowBluetoothA2DP, .allowAirPlay])
            }
            try setCategory(AVAudioSessionCategoryPlayAndRecord, with: options)
            try setActive(true)
        }
    }
}
