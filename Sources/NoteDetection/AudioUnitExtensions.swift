import Foundation
import CoreAudio
import AudioToolbox

extension AudioUnit {
    static func createInputUnit(sampleRate: Float64, numberOfChannels: UInt32) throws -> AudioUnit {
        let inputUnit = try AudioComponent(
            description: AudioComponentDescription(
                componentType           : kAudioUnitType_Output,
                componentSubType        : kAudioUnitSubType_RemoteIO,
                componentManufacturer   : kAudioUnitManufacturer_Apple,
                componentFlags          : 0,
                componentFlagsMask      : 0
            )
        )

        // Set format to 32-bit Floats, linear PCM
        let sizeOfFloat32 = UInt32(MemoryLayout<Float32>.size)
        let streamFormat = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsFloat,
            mBytesPerPacket: numberOfChannels * sizeOfFloat32,
            mFramesPerPacket: 1, // "In linear PCM audio, a packet holds a single frame." https://goo.gl/DsUwof
            mBytesPerFrame: numberOfChannels * sizeOfFloat32,
            mChannelsPerFrame: UInt32(numberOfChannels),
            mBitsPerChannel: 32, // a Float32 has 32 bits
            mReserved: 0
        )

        // Apple Resource for Audio Unit Hosting: https://goo.gl/SN1OlC
        // Doing this requires us to manage audio output manually, since by default iOS sets audio output to receiver

        // XXX: @rikner - we still have audio output from video without setting the output, can we delete this?
        try inputUnit.setProperty(kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, .outputBus, UInt32(true))

        try inputUnit.setProperty(kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, .inputBus, streamFormat)
        try inputUnit.setProperty(kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, .outputBus, streamFormat)

        return inputUnit
    }
}

// Generalisable helpers (not specific to our implementation):
extension AudioUnit {
    func getProperty<PropertyData>
        (_ propertyID: AudioUnitPropertyID, _ scope: AudioUnitScope, _ element: AudioUnitElement) -> PropertyData? {
        let data = UnsafeMutablePointer<PropertyData>.allocate(capacity: 1)
        defer { data.deallocate(capacity: 1) }

        do {
            var size = UInt32(MemoryLayout<PropertyData>.size)
            try AudioUnitGetProperty(self, propertyID, scope, element, data, &size).throwOnError()
            return data.pointee
        } catch {
            return nil
        }
    }

    func setProperty<PropertyData>
    (_ propertyID: AudioUnitPropertyID, _ scope: AudioUnitScope, _ element: AudioUnitElement, _ data: PropertyData)
    throws {
        var data = data
        try AudioUnitSetProperty(
            self,
            propertyID,
            scope,
            element,
            &data,
            UInt32(MemoryLayout<PropertyData>.size)
        ).throwOnError()
    }

    func start() throws { try AudioOutputUnitStart(self).throwOnError() }
    func stop() throws { try AudioOutputUnitStop(self).throwOnError() }

    /// Allocates memory. Once inited, internal state cannot be changed.
    func initialize() throws { try AudioUnitInitialize(self).throwOnError() }

    /// Deallocate memory and allow internal state to be changed without destroying the instance entirely
    func uninitialize() throws { try AudioUnitUninitialize(self).throwOnError() }

    /// Opposite of AudioComponentInstanceNew()
    func dispose() throws { try AudioComponentInstanceDispose(self).throwOnError() }
}

extension AudioUnitElement {
    static let inputBus = AudioUnitElement(1) // 1nput
    static let outputBus = AudioUnitElement(0) // 0utput
}

private extension AudioComponent {
    enum AudioComponentError: Error {
        case componentNotFound
    }

    init(description: AudioComponentDescription) throws {
        var description = description
        guard let audioComponent = AudioComponentFindNext(nil, &description) else {
            throw AudioComponentError.componentNotFound
        }

        // Obtain an audio unit instance of the component
        var audioUnit: AudioUnit?
        try AudioComponentInstanceNew(audioComponent, &audioUnit).throwOnError()

        // We should have thrown an error above if the component couldn't be created (i.e. is nil):
        precondition(audioUnit != nil)
        self = audioUnit!
    }
}
