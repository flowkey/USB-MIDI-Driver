import Foundation

public protocol NoteDetectorDelegate: class {
    func onNoteEventDetected(
        noteDetector: NoteDetector,
        timestamp: TimeInterval,
        detectedEvent: DetectableNoteEvent
    ) -> Void
    func onInputLevelChanged(ratio: Float) -> Void
}

/// Common public interface for audio and MIDI note detection
public protocol NoteDetector {
    var delegate: NoteDetectorDelegate? { get set }
    var expectedNoteEvent: DetectableNoteEvent? { get set }
}
