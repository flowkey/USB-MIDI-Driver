# NoteDetection

## Build on macOS
#### Prerequirements:
To build for Android: Swifty Robot (see SDL Player README on how to setup Swifty Robot)
### Via XCode (for iOS and Android)
- build for iOS with _NoteDetection_ XCode target
- build for Android with _NoteDetectionAndroid_ XCode target

### Via Command Line (for Android)
- first build the CAndroidAudioEngine, which we can later import in Swift: `cd Sources/CAndroidAudioEngine ; ./build.sh`
- then build the actual Swift Package via Swifty Robot: `./build_android.sh`

### Via VSCode (for Android)
- `SHIFT+CMD+B` starts vscode build task which executes `./build_android.sh` with build output

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
