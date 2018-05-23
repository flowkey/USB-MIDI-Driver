# Building the NoteDetection

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

# API

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



# How it works


What we want to achieve with the note event detection is to compare an audio signal to a set of expected 
MIDI numbers and decide whether the audio signal matches this set. 
If they match we continue to the next set of expected MIDI numbers, which means that the video 
player progresses to the next position with notes.


## Overview

The note detection consists basically of 4 parts:
Preprocessing, Onset Detection, Pitch Detection and a final Decision step.
The following diagram shows the processing steps each audio frame from the microphone passes:

```


                                                      |ONSET DETECTION|
                                                     /                \
audio frame -> |PREPROCESSING| -> filter magnitudes ->                  -> timestamps -> |DECISION LOGIC| -> bool
                                                     \                /
                                                      |PITCH DETECTION|

```
## Preprocessing

In order to provide data input for the onset and pitch detection, the audio signal is send through a filterbank,
which consists of 8*12 bandpass filters. Each filter corresponds to one key on a piano. The output is an array
of 96 filter magnitudes, which serves as input data for the onset as well as for the pitch detection.


## Pitch Detection

With the pitch detection we want to estimate the similarity between the microphone signal and the expected notes.
To achieve that, we first calculate a pitch class profile (chroma vector) from the current filterbank magnitudes.
As a second set of input data the pitch detection receives the currently expected MIDI numbers, in order to
calculate an expected pitch class profile from these MIDI numbers.
Here we try to take into account potential harmonics in real world pianos: For low MIDI numbers,
we do not only model the actual pitch class but also the pitch class which is 7 semitones up from that class.
This way we take the perfect fifth into account, which often resonates with the actual pitch frequency.
This approach is not very sophisticated and there are probably better models to think of.
The benefit here is, that this approach is computationally inexpensive and does not need any real world audio data.
We calculate the cosine similarity between the 'filterbank' pitch class profile and the 'midi' pitch class profile.
If the similarity is above a certain threshold (we use something around 0.7 with some tolerance here and there), 
the pitch detection issues a pitch timestamp which serves as input data for the final decision step.


## Onset Detection

The onset detection serves as a way to distinguish consecutive note events from each other. 
If there is a note which has to be played two times in row, we need to know if the user actually played the note
two times or just one time.
The first step here is to calculate an audio feature. We use the Spectral Flux based on the incoming filter magnitudes.
Then we use a moving average of recent spectral flux values to calculate a threshold value.
The threshold serves as criteria to identify if the previously calculated Spectral Flux value is a local maxima.
A local maxima is detected if the Spectral Flux value is
a) above the current threshold and
b) it's bigger than its predecessor and successor
If a local maxima and therefore an onset detected the onset detection indicates this by outputting an onset timestamp.


## Decision Logic

The decision step takes the onset timestamps and pitch timestamps and compares them. If they are close enough, 
the player moves on to the next note event and all timestamps are cleared. Now the logic waits for new onset 
and pitch timestamps to arrive.