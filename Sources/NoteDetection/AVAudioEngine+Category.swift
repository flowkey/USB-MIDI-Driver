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
        if category != .playAndRecord {
            try setActive(false)
            try setCategoryToPlayAndRecordWithCustomOptions()
            try setActive(true)
        }
    }
}

public extension AVAudioSession {
    func setCategoryToPlayAndRecordWithCustomOptions() throws {
        var options: AVAudioSession.CategoryOptions = [.defaultToSpeaker]
        
        if #available(iOS 10.0, *) {
            options.insert([.allowBluetoothA2DP, .allowAirPlay])
            try AVAudioSession.sharedInstance().setCategory(.playAndRecord,
                                                            mode: .measurement,
                                                            options: options)
        } else {
            options.insert([.allowBluetooth])

            // use workaround to set category with options because of http://www.openradar.me/42382075
            AVAudioSession.sharedInstance().perform(
                NSSelectorFromString("setCategory:withOptions:error:"),
                with: AVAudioSession.Category.playAndRecord,
                with: options
            )
        }
    }
}
