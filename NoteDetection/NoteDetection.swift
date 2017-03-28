//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import FlowCommons

public protocol NoteDetectionProtocol {
    var inputType: InputType { get }
//    var onInputLevelChanged: ((Float) -> Void)? { get set }

    func start()
    func stop()

    func setExpectedEvent(noteEvent: NoteEvent)
    var onEventDetected: (() -> Void)? { get set }
}

public enum InputType {
    case audio
    case midi
}
