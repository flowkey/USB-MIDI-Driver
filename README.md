# NoteDetection

## Build on macOS
#### Prerequirements:
To build for Android: Swifty Robot (see SDL Player README on how to setup Swifty Robot)
### Via XCode (for iOS and Android)
- build for iOS with _NoteDetection_ XCode target
- build for Android with _NoteDetectionAndroid_ XCode target

### Via Command Line (for Android)
- build the Swift Package via Swifty Robot: `./build_android.sh`

### Via VSCode (for Android)
- `SHIFT+CMD+B` starts vscode build task which executes `./build_android.sh` with build output

## API:

```
public class NoteDetection {
    init(inputType: InputType)
    var inputType: InputType { get set }
    var midiDeviceList: Set<MIDIDevice> { get }
    func set(onMIDIDeviceListChanged: MIDIDeviceListChangedCallback?)
    func set(onInputLevelChanged: InputLevelChangedCallback?)
    func set(onAudioProcessed: AudioProcessedCallback?)
    func set(expectedNoteEvent: DetectableNoteEvent?)
    func set(onNoteEventDetected: NoteEventDetectedCallback?)
    func ignoreFor(ms duration: Double)
    func startInput() throws
    func stopInput() throws
}
```
