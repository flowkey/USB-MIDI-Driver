//
//  NoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 24.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

public typealias OnInputLevelChangedCallback = ((Float) -> Void)

public class NoteDetection {

    var inputType: InputType {
        get { return noteDetector is AudioNoteDetector ? .audio : .midi }
        set {
            noteDetector = createNoteDetector(type: newValue, copy: noteDetector)
            switch noteDetector {
            case let noteDetector as AudioNoteDetector: audioEngine.onAudioData = noteDetector.process
            case let noteDetector as MIDINoteDetector: midiEngine.onMIDIMessageReceived = noteDetector.process
            default: return
            }
        }
    }

    // explicitly unwrapped to be able to use createNoteDetector() in init, which needs self.audioEngine
    var noteDetector: NoteDetector!

    let midiEngine = try! MIDIEngine()
    let audioEngine = try! AudioEngine()

    public var onInputLevelChanged: OnInputLevelChangedCallback?

    public init(type: InputType) {
        noteDetector = createNoteDetector(type: .audio)

        audioEngine.onSamplerateChanged = { sampleRate in
            if self.inputType == .audio {
                self.noteDetector = self.createNoteDetector(type: .audio, copy: self.noteDetector)
            }
        }

//        midiEngine.onVelocityChanged = { (vel: UInt8) in
//            self.onInputLevelChanged?(Float(vel) / 127.0)
//        }
//
//        audioEngine.onVolumeChanged = { (vol: Float) in
//            // TODO: check for < 0
//            self.onInputLevelChanged?(1 - (vol / -72))
//        }
    }

    deinit {
        print("deiniting NoteDetection")
    }

}


// MARK: Public Interface

extension NoteDetection {

    public func set(expectedNoteEvent: NoteEvent?) {
        noteDetector.expectedNoteEvent = expectedNoteEvent
    }

    public func set(onNoteEventDetected: OnNoteEventDetectedCallback?) {
        noteDetector.onNoteEventDetected = onNoteEventDetected
    }

    public func set(onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback?) {
        midiEngine.onMIDIDeviceListChanged = onMIDIDeviceListChanged
    }

    public func startAudioEngine() {
        try? audioEngine.start()
    }

    public func stopAudioEngine() {
        try? audioEngine.stop()
    }
}

protocol NoteDetector {
    var onNoteEventDetected: OnNoteEventDetectedCallback? { get set }
    var expectedNoteEvent: NoteEvent? { get set }
}

extension NoteDetection {
    func createNoteDetector(type: InputType, copy previousDetector: NoteDetector? = nil) -> NoteDetector {
        var newNoteDetector: NoteDetector
        switch type {
            case .audio: newNoteDetector = AudioNoteDetector(sampleRate: audioEngine.sampleRate)
            case .midi: newNoteDetector = MIDINoteDetector()
        }
        newNoteDetector.expectedNoteEvent = previousDetector?.expectedNoteEvent
        newNoteDetector.onNoteEventDetected = previousDetector?.onNoteEventDetected
        return newNoteDetector
    }
}
