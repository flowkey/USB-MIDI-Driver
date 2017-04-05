//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//



final class MIDINoteDetector: NoteDetector {
    let midiEngine = try? MIDIEngine()
    let follower = MIDIFollower()

    public var onMIDIMessageReceived: OnMIDIMessageReceivedCallback? {
        didSet {
            midiEngine?.onMIDIMessageReceived = { message, device in
                self.follower.onMIDIMessageReceived(message)
                self.onMIDIMessageReceived?(message, device)
            }
        }
    }

    func start() {}
    func stop() {}

    public var onNoteEventDetected: OnNoteEventDetectedCallback? {
        didSet { follower.onNoteEventDetected = onNoteEventDetected }
    }

    public var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback? {
        didSet { midiEngine?.onMIDIDeviceListChanged = onMIDIDeviceListChanged }
    }

    public func setExpectedNoteEvent(noteEvent: NoteEvent?) {
        follower.currentNoteEvent = noteEvent
    }
}
