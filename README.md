# NoteDetection

## Build for iOS:
- build via XCode (open NoteDetection.xcworkspace to also build test environment)

## Build for Android:
- on macOS build with Swifty Robot (`sr build`) (see SDL Player README on how to setup Swifty Robot)
- there is also a VS Code task to trigger `sr build` via `SHIFT`+`CMD`+`B`

## API:

```
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
