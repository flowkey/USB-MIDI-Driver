import Dispatch

protocol LightController {
    var midiEngine: MIDIEngineProtocol? { get }
    var connection: MIDIOutConnection? { get }

    static func createLightOnMessage(key: UInt8) -> [UInt8]
    static func createLightOffMessage(key: UInt8) -> [UInt8]

    func animateLights(onComplete: ((LightController) -> Void)?)
    func turnOnLights(at index: Int, in noteEvents: [DetectableNoteEvent])
    func turnOffAllLights()
}

extension LightController {
    func send(messages: [[UInt8]]) {
        guard let connection = self.connection else {
            print("light control can not send messages because outConnection does not exist.")
            return
        }
        guard let midiEngine = self.midiEngine else {
            print("light control can not send messages because midiEngine does not exist.")
            return
        }
        midiEngine.send(messages: messages, to: connection)
    }

    func animateLights(onComplete: ((LightController) -> Void)?) {
        let animationTimeMS = 500
        let pianoMIDIRange = 21..<109
        let animationTimePerKeyMS = animationTimeMS / pianoMIDIRange.count
        let startTime = DispatchTime.now()

        // trigger animation (async)
        for key in pianoMIDIRange {
            let noteOnMsg = Self.createLightOnMessage(key: UInt8(key))
            let noteOffMsg = Self.createLightOffMessage(key: UInt8(key))

            DispatchQueue.main.asyncAfter(deadline: startTime + .milliseconds(key * animationTimePerKeyMS), execute: {
                self.send(messages: [noteOnMsg])
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(key * animationTimePerKeyMS), execute: {
                    self.send(messages: [noteOffMsg])
                })
            })
        }

        DispatchQueue.main.asyncAfter(deadline: startTime + .milliseconds(1200), execute: {
            onComplete?(self)
        })
    }
}
