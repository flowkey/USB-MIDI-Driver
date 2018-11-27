// Taken from https://github.com/AudioKit/AudioKit/blob/master/AudioKit/Common/MIDI/AKMIDI%2BSendingMIDI.swift

import CoreMIDI

let sizeOfMIDIPacketList = MemoryLayout<MIDIPacketList>.size
let sizeOfMIDIPacket = MemoryLayout<MIDIPacket>.size

/// The `MIDIPacketList` struct consists of two fields, numPackets(`UInt32`) and
/// packet(an Array of 1 instance of `MIDIPacket`). The packet is supposed to be a "An open-ended
/// array of variable-length MIDIPackets." but for convenience it is instantiated with
/// one instance of a `MIDIPacket`. To figure out the size of the header portion of this struct,
/// we can get the size of a UInt32, or subtract the size of a single packet from the size of a
/// packet list. I opted for the latter.
let sizeOfMIDIPacketListHeader = sizeOfMIDIPacketList - sizeOfMIDIPacket

/// The MIDIPacket struct consists of a timestamp (`MIDITimeStamp`), a length (`UInt16`) and
/// data (an Array of 256 instances of `Byte`). The data field is supposed to be a "A variable-length
/// stream of MIDI messages." but for convenience it is instantiated as 256 bytes. To figure out the
/// size of the header portion of this struct, we can add the size of the `timestamp` and `length`
/// fields, or subtract the size of the 256 `Byte`s from the size of the whole packet. I opted for
/// the former.
let sizeOfMIDIPacketHeader = MemoryLayout<MIDITimeStamp>.size + MemoryLayout<UInt16>.size
let sizeOfMIDICombinedHeaders = sizeOfMIDIPacketListHeader + sizeOfMIDIPacketHeader
