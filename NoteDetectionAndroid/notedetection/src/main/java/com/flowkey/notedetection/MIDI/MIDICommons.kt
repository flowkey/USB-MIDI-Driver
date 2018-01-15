package com.flowkey.notedetection.midi

class MIDIDevice(
    val model: String,
    val manufacturer: String,
    val uniqueID: Int
)

typealias MIDIDeviceChangedCallback = (midiDevices: Array<MIDIDevice>) -> Unit
typealias MIDIMessageReceivedCallback = (msg: ByteArray, offset: Int, count: Int, timestamp: Long) -> Unit

interface MIDIEngine {
    var onMIDIDeviceChanged: MIDIDeviceChangedCallback?
    var onMIDIMessageReceived: MIDIMessageReceivedCallback?
}
