//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//


public class NoteDetection {
    var noteDetector: NoteDetector
    let audioEngine = try! AudioEngine()
    let midiEngine = try! MIDIEngine()

    public init(type: InputType) {
        //noteDetector = type.createNoteDetector()
        noteDetector = AudioNoteDetector(sampleRate: audioEngine.sampleRate)
    }

    public func setInputType(to type: InputType) {
        stop()
    }

    public func start() { // start audio engine only
        try? audioEngine.start()
    }

    public func stop() {
        try? audioEngine.stop()
    }

    public func setExpectedNoteEvent(event: NoteEvent?) {
        noteDetector.setExpectedNoteEvent(noteEvent: event)
    }

    deinit {
        print("deiniting NoteDetection")
    }
}

protocol NoteDetector {
    var onNoteEventDetected: OnNoteEventDetectedCallback? { get set }
    func setExpectedNoteEvent(noteEvent: NoteEvent?)
}
