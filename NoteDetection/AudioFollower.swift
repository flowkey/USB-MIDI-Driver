//
//  AudioFollower.swift
//  Follower
//
//  Created by flowing erik on 26.09.16.
//  Copyright © 2016 flowkey GmbH. All rights reserved.
//

public final class AudioFollower: Follower {
    public init() {}

    /// A Double signifying the time an event arrived, in milliseconds
    // TODO: use timestamp in Onset and NoteDetection 
    public typealias Timestamp = Double

    private let timeToNextToleranceFactor = 0.5
    private let maxTimestampDiff = Timestamp(200)
    private var onsetTimestamp: Timestamp?
    private var noteTimestamp: Timestamp?
    private var lastFollowEventTime: Timestamp?

    public var currentNoteEvent: NoteEvent?
    public var onFollow: Follower.EventListener?

    public func onOnsetDetected(timestamp: Timestamp) {
        guard currentlyAcceptingOnsets() else { return }
        onsetTimestamp = timestamp
        onInputReceived()
    }

    public func onPitchDetected(timestamp: Timestamp, pitchDetectionData: PitchDetectionData? = nil) {
        noteTimestamp = timestamp
        onInputReceived()
    }

    public func shouldFollow() -> Bool {
        return timestampsAreCloseEnough()
    }

    func now() -> Timestamp {
        return getTimeInMillisecondsSince1970()
    }

    func currentlyAcceptingOnsets() -> Bool {
        guard
            let lastFollowEventTime = lastFollowEventTime,
            let timeToNextEvent = currentNoteEvent?.timeToNext
            else {
                return true
        }
        return now() - lastFollowEventTime >= (timeToNextEvent * timeToNextToleranceFactor)
    }

    private func timestampsAreCloseEnough() -> Bool {
        guard
            let onsetTimestamp = onsetTimestamp,
            let noteTimestamp = noteTimestamp
            else { return false }

//        print("noteTimestamp - onsetTimestamp = ", noteTimestamp - onsetTimestamp)
        let timestampDiff = abs(onsetTimestamp - noteTimestamp)
        return timestampDiff < maxTimestampDiff
    }

    public func didFollow() {
        self.lastFollowEventTime = now()
        self.onsetTimestamp = nil
        self.noteTimestamp = nil
    }
}
