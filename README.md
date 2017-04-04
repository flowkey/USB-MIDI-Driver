(ToDo: replace this document with actual documentation or readme)

## Note Detection Refactor Changes

#### - PitchDetection module is now called NoteDetection
#### - what was NoteDetection class is now PitchDetection class
#### - renamed AudioProcessor to AudioNoteDetection: conforms to NoteDetectionProtocol
#### - introduced MIDINoteDetection: conforms to NoteDetectionProtocol
#### - integrated Follower into NoteDetection module
#### - killed FlowCommons, moved its code to NoteDetection or PlayerLogic
#### - renamed MidiNumber to MIDINumber

#### - AudioEngine.swift:
- has no audioProcessor anymore
- audioIOUnit is now optional (instead of explicitly unwrapped optional)
- onAudioData is now a class property instead of top level function

#### - MIDIManager.swift:
- killed sharedInstance
- use unsafeBitCast and refCons to get reference on midiManager in Procedures
- rename some functions and minor refactoring
- use OSStatus extension throwOnError


