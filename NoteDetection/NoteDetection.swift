//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import FlowCommons

public typealias OnInputLevelRatioChangedCallback = (Float) -> Void
public typealias OnNoteEventDetectedCallback = () -> Void

public class NoteDetection {
    var noteDetection: NoteDetectionProtocol

    public init(type: InputType) {
        noteDetection = type.createNoteDetection()
    }

    public var onInputLevelRatioChanged: OnInputLevelRatioChangedCallback? {
        didSet { noteDetection.onInputLevelRatioChanged = onInputLevelRatioChanged }
    }

    public var onNoteEventDetected: OnNoteEventDetectedCallback? {
        didSet { noteDetection.onNoteEventDetected = onNoteEventDetected }
    }

    public var inputType: InputType {
        get { return noteDetection.inputType }
        set { noteDetection = newValue.createNoteDetection() }
    }

    public func start() {
        let audioNoteDetection = noteDetection as? AudioNoteDetection
        audioNoteDetection?.start()
    }

    public func stop() {
        let audioNoteDetection = noteDetection as? AudioNoteDetection
        audioNoteDetection?.stop()

    }

    public func setExpectedNoteEvent(event: NoteEvent) {
        noteDetection.setExpectedNoteEvent(noteEvent: event)
    }
}

protocol NoteDetectionProtocol {
    var inputType: InputType { get }
    var onInputLevelRatioChanged: OnInputLevelRatioChangedCallback? { get set }

    var onNoteEventDetected: OnNoteEventDetectedCallback? { get set }
    func setExpectedNoteEvent(noteEvent: NoteEvent)
}
