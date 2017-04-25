# NoteDetection

## API:

```
}
public class NoteDetection {

    public init(input: NoteDetection.InputType) throws

    public var inputType: NoteDetection.InputType

    public var midiDeviceList: Set<NoteDetection.MIDIDevice> { get }

    public func set(onInputLevelChanged: NoteDetection.InputLevelChangedCallback?)

    public func set(expectedNoteEvent: DetectableNoteEvent?)

    public func set(onNoteEventDetected: NoteDetection.NoteEventDetectedCallback?)

    public func set(onMIDIDeviceListChanged: NoteDetection.MIDIDeviceListChangedCallback?)

    public func startMicrophone() throws

    public func stopMicrophone() throws
}
```
