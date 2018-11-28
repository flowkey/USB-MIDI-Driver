//
//  NoteDetectorTestDelegate.swift
//  NoteDetectionTests
//
//  Created by Erik Werner on 11.07.18.
//  Copyright © 2018 flowkey. All rights reserved.
//

@testable import NoteDetection

class NoteDetectorTestDelegate: NoteDetectorDelegate {
    
    var callback: () -> Void
    
    init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    func onNoteEventDetected(
        noteDetector: NoteDetector,
        timestamp: TimeInterval,
        detectedEvent: DetectableNoteEvent
    ) {
        callback()
    }
    
    func onInputLevelChanged(ratio: Float) {}
    var expectedNoteEvent: DetectableNoteEvent?
    
    public func set(expectedNoteEvent: DetectableNoteEvent?) {
        self.expectedNoteEvent = expectedNoteEvent
    }
}
