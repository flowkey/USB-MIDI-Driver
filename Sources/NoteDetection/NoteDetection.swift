import Foundation

#if os(Android)
import JNI
public typealias MIDITime = JavaLong
#else
import CoreMIDI
public typealias MIDITime = CoreMIDI.MIDITimeStamp
#endif

public typealias AudioTime = Double

public protocol NoteDetectorDelegate: class {
    func onNoteEventDetected(
        noteDetector: NoteDetector,
        timestamp: TimeInterval,
        detectedEvent: DetectableNoteEvent
    ) -> Void
    func onInputLevelChanged(ratio: Float) -> Void
    var expectedNoteEvent: DetectableNoteEvent? { get }
}

/// Common public interface for audio and MIDI note detection
public protocol NoteDetector {
    var delegate: NoteDetectorDelegate? { get set }
}
