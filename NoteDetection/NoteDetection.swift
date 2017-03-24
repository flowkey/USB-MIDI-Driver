//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import Foundation

public protocol NoteDetection {
    func start()
    func stop()
    func setExpectedEvent()
    func setInputType(type: InputType)

    var onEventDetected: (() -> Void)? { get set }
    var onInputLevelChanged: ((Float) -> Void)? { get set }
    var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback? { get set }
}

public enum InputType {
    case audio
    case midi
}
