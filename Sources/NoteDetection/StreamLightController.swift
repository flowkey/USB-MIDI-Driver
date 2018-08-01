import Foundation

class StreamLightController: LightController {
    static let supportedModels = Set(["CSP-170", "CSP-150"])

    weak var midiEngine: MIDIEngineProtocol?
    weak var connection: MIDIOutConnection?
    
    var isEnabled = true {
        didSet {
            if isEnabled == oldValue { return }
            if isEnabled == true {
                animateLights { self.turnOnLights(at: self.noteEvents) }
            } else {
                turnOffAllLights()
            }
        }
    }

    var noteEvents: [DetectableNoteEvent] = [] {
        didSet {
            turnOffAllLights()
            turnOnLights(at: self.noteEvents)
        }
    }

    func turnOnLights(at noteEvents: [DetectableNoteEvent]) {
        for (ledRow, noteEvent) in noteEvents.enumerated() {
            let keys = noteEvent.notes.map{ UInt8($0) }
            let mode: LEDMode = (ledRow == 0) ? .flash : .on
            keys.forEach { key in
                let message = createStreamLightsOnOffMessage(key: key, ledRow: UInt8(ledRow), mode: mode)
                if isEnabled {
                    send(messages: [message])
                }
            }
        }
    }
    
    init(connection: MIDIOutConnection?, midiEngine: MIDIEngineProtocol?) {
        self.connection = connection
        self.midiEngine = midiEngine

        animateLights { self.turnOnLights(at: self.noteEvents) }
    }
    
    deinit {
        self.turnOffAllLights()
    }
    
    func turnOffAllLights() {
        self.send(messages: [YamahaMessages.TURN_OFF_ALL_STREAM_LIGHTS])
    }
    
    func animateLights(onComplete: (() -> Void)?) {
        let animationTimeMS = 500
        let pianoMIDIRange = 24..<112
        let animationTimePerKeyMS = animationTimeMS / pianoMIDIRange.count
        let startTime = DispatchTime.now()
        
        
        // trigger animation (async)
        for key in pianoMIDIRange {
            let noteOnMsg = createStreamLightsOnOffMessage(key: UInt8(key), ledRow: 0, mode: .on)
            let noteOffMsg = createStreamLightsOnOffMessage(key: UInt8(key), ledRow: 0, mode: .off)
            
            DispatchQueue.main.asyncAfter(deadline: startTime + .milliseconds(key * animationTimePerKeyMS), execute: {
                self.send(messages: [noteOnMsg])
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(key * animationTimePerKeyMS), execute: {
                    self.send(messages: [noteOffMsg])
                })
            })
        }
        
        DispatchQueue.main.asyncAfter(deadline: startTime + .milliseconds(1200), execute: {
            onComplete?()
        })
    }
}
