import Foundation

private let NOTE_ON: UInt8 = 9
private let NOTE_OFF: UInt8 = 8

class RegularLightController: LightController {
    static let supportedModels = Set(["CVP-701", "CVP-705", "CVP-709", "CVP-709GP"])
    
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
            turnOffLights(at: oldValue)
            turnOnLights(at: self.noteEvents)
        }
    }
    
    init(connection: MIDIOutConnection?, midiEngine: MIDIEngineProtocol?) {
        self.connection = connection
        self.midiEngine = midiEngine
        
        self.send(messages: [YamahaMessages.GUIDE_ON])
        self.send(messages: [YamahaMessages.LIGHT_ON_NO_SOUND])
        
        animateLights { self.turnOnLights(at: self.noteEvents) }
    }
    
    deinit {
        self.turnOffAllLights()
    }

    private func turnOnLights(at noteEvents: [DetectableNoteEvent]) {
        guard isEnabled, let noteEvent = noteEvents.first
            else { return }
        let keys = noteEvent.notes.map{ UInt8($0) }
        let messages = keys.map { createLightOnMessage(key: $0) }
        send(messages: messages)
    }
    
    private func turnOffLights(at noteEvents: [DetectableNoteEvent]) {
        guard let noteEvent = noteEvents.first
            else { return }
        let messages = noteEvent.notes.map { createLightOffMessage(key: UInt8($0)) }
        send(messages: messages)
    }
    
    private func turnOffAllLights() {
        (0..<128).forEach {
            let message = createLightOffMessage(key: UInt8($0))
            send(messages: [message])
        }
    }
    
    func animateLights(onComplete: (() -> Void)?) {
        let animationTimeMS = 500
        let pianoMIDIRange = 24..<112
        let animationTimePerKeyMS = animationTimeMS / pianoMIDIRange.count
        let startTime = DispatchTime.now()
        
        // trigger animation (async)
        for key in pianoMIDIRange {
            let noteOnMsg = createLightOnMessage(key: UInt8(key))
            let noteOffMsg = createLightOffMessage(key: UInt8(key))

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

    
func createLightOnMessage(key: UInt8, velocity: UInt8 = 2) -> [UInt8] {
    return [(NOTE_ON << 4) | .LIGHT_CONTROL_CHANNEL, key, velocity]
}

func createLightOffMessage(key: UInt8, velocity: UInt8 = 0) -> [UInt8] {
    return [(NOTE_OFF << 4) | .LIGHT_CONTROL_CHANNEL, key, velocity]
}
