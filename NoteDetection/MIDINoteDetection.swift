//
//  MIDINoteDetection.swift
//  NoteDetection
//
//  Created by flowing erik on 28.03.17.
//  Copyright © 2017 flowkey. All rights reserved.
//

import FlowCommons

final class MIDINoteDetection: NoteDetectionProtocol {

    public let inputType: InputType = .midi

    let midiManager = try? MIDIManager()

    let follower = MIDIFollower()

    public var onInputLevelRatioChanged: OnInputLevelRatioChangedCallback?

    public var onMIDIMessageReceived: OnMIDIMessageReceivedCallback? {
        didSet {
            midiManager?.onMIDIMessageReceived = { message, device in
                self.follower.onMIDIMessageReceived(message)
                self.onMIDIMessageReceived?(message, device)
                switch message {
                    case .noteOn(let (_, velocity)): self.onInputLevelRatioChanged?(Float(velocity) / 127.0)
                    case .noteOff(let (_, velocity)): self.onInputLevelRatioChanged?(Float(velocity) / 127.0)
                    default: break
                }
            }
        }
    }

    public init() {}

    public var onNoteEventDetected: OnNoteEventDetectedCallback? {
        didSet { follower.onFollow = onNoteEventDetected }
    }

    public var onMIDIDeviceListChanged: OnMIDIDeviceListChangedCallback? {
        didSet { midiManager?.onMIDIDeviceListChanged = onMIDIDeviceListChanged }
    }

    public func setExpectedNoteEvent(noteEvent: NoteEvent?) {
        follower.currentNoteEvent = noteEvent
    }
}
