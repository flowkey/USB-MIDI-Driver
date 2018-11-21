public protocol NoteDetectorDelegate: class {
    func onNoteEventDetected<Numeric>(
        noteDetector: NoteDetector,
        timestamp: Numeric,
        detectedEvent: DetectableNoteEvent
    ) -> Void
    func onInputLevelChanged(ratio: Float) -> Void
    var expectedNoteEvent: DetectableNoteEvent? { get }
}

/// Common public interface for audio and MIDI note detection
public protocol NoteDetector {
    var delegate: NoteDetectorDelegate? { get set }
}
