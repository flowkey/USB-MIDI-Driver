//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import FlowCommons

public typealias OnInputLevelRatioChangedCallback = (Float) -> Void

public class NoteDetection {
    let audioNoteDetection = AudioNoteDetection()
    let midiNoteDetection = MIDINoteDetection()

    public init(type: InputType) {
        inputType = type
    }

    public var onNoteEventDetected: OnNoteEventDetectedCallback? {
        didSet {
            audioNoteDetection.onNoteEventDetected = onNoteEventDetected
            midiNoteDetection.onNoteEventDetected = onNoteEventDetected
        }
    }

    public var onAudioProcessed: OnAudioProcessedCallback? {
        didSet { audioNoteDetection.onAudioProcessed = onAudioProcessed }
    }

    public var onMIDIMessageReceived: OnMIDIMessageReceivedCallback? {
        didSet { midiNoteDetection.onMIDIMessageReceived = onMIDIMessageReceived }
    }

    public var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback? {
        didSet { midiNoteDetection.onMIDIDeviceListChanged = onMIDIDeviceListChanged }
    }

    public var onVolumeUpdated: OnVolumeUpdatedCallback? {
        didSet { audioNoteDetection.onVolumeUpdated = onVolumeUpdated }
    }

    public var onOnsetDetected: OnOnsetDetectedCallback? {
        didSet { audioNoteDetection.onOnsetDetected = onOnsetDetected }
    }

    public var inputType: InputType {
        willSet {
            if inputType == .audio && newValue == .midi {
                self.stop()
            }
        }
    }

    public func start() {
        if inputType == .audio { audioNoteDetection.start() }
    }

    public func stop() {
        if inputType == .audio { audioNoteDetection.stop() }
    }

    public func setExpectedNoteEvent(event: NoteEvent?) {
        audioNoteDetection.setExpectedNoteEvent(noteEvent: event)
        midiNoteDetection.setExpectedNoteEvent(noteEvent: event)
    }
}

protocol NoteDetectionProtocol {
    var inputType: InputType { get }
    var onInputLevelRatioChanged: OnInputLevelRatioChangedCallback? { get set }

    var onNoteEventDetected: OnNoteEventDetectedCallback? { get set }
    func setExpectedNoteEvent(noteEvent: NoteEvent?)
}
