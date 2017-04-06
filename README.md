# NoteDetection

## API:

```
public class NoteDetection {
    public var inputType: NoteDetection.InputType
    
    public init(type: NoteDetection.InputType) throws

    public var onInputLevelChanged: NoteDetection.InputLevelChangedCallback?
    public func set(expectedNoteEvent: DetectableNoteEvent?)
    public func set(onNoteEventDetected: NoteDetection.NoteEventDetectedCallback?)
    public func set(onMIDIDeviceListChanged: NoteDetection.MIDIDeviceListChangedCallback?)
    
    public func startMicrophone() throws
    public func stopMicrophone() throws

    public func overrideInputType(to type: NoteDetection.InputType)
}
```
