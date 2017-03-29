//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import FlowCommons

public typealias OnInputLevelRatioChangedCallback = (Float) -> Void
public typealias OnEventDetectedCallback = () -> Void

public protocol NoteDetectionProtocol {
    var inputType: InputType { get }
    func setExpectedEvent(noteEvent: NoteEvent)
    var onEventDetected: OnEventDetectedCallback? { get set }
    var onInputLevelRatioChanged: OnInputLevelRatioChangedCallback? { get set }
}

public enum InputType {
    case audio
    case midi

    func createNoteDetection() -> NoteDetectionProtocol {
        switch self {
        case .audio: return AudioNoteDetection()
        case .midi: return MIDINoteDetection()
        }
    }
}


public class NoteDetection {

    var noteDetection: NoteDetectionProtocol
    var onInputLevelRatioChanged: OnInputLevelRatioChangedCallback? {
        didSet { noteDetection.onInputLevelRatioChanged = onInputLevelRatioChanged }
    }

    var inputType: InputType {
        get { return noteDetection.inputType }
        set { noteDetection = newValue.createNoteDetection() }
    }

    init(type: InputType) {
        noteDetection = type.createNoteDetection()
    }

    func start() {
        if noteDetection.inputType == .audio {
            let audioNoteDetection = noteDetection as? AudioNoteDetection
            audioNoteDetection?.start()
        }
    }

    func stop() {
        if noteDetection.inputType == .audio {
            let audioNoteDetection = noteDetection as? AudioNoteDetection
            audioNoteDetection?.stop()
        }
    }
}
