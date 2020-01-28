package com.flowkey.notedetection.midi

import android.content.Context
import android.hardware.usb.UsbDevice
import android.os.Build
import android.os.Looper


import java.util.*
import androidx.annotation.RequiresApi
import jp.kshoji.driver.midi.device.MidiInputDevice
import jp.kshoji.driver.midi.device.MidiOutputDevice
import jp.kshoji.driver.midi.util.UsbMidiDriver

@RequiresApi(api = Build.VERSION_CODES.KITKAT)
internal class MIDIEngineKitkat(context: Context): MIDIEngine, UsbMidiDriver(context) {
    override fun onMidiMiscellaneousFunctionCodes(sender: MidiInputDevice, cable: Int, byte1: Int, byte2: Int, byte3: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiCableEvents(sender: MidiInputDevice, cable: Int, byte1: Int, byte2: Int, byte3: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiSystemCommonMessage(sender: MidiInputDevice, cable: Int, bytes: ByteArray?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiSystemExclusive(sender: MidiInputDevice, cable: Int, systemExclusive: ByteArray?) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiPolyphonicAftertouch(sender: MidiInputDevice, cable: Int, channel: Int, note: Int, pressure: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiProgramChange(sender: MidiInputDevice, cable: Int, channel: Int, program: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiChannelAftertouch(sender: MidiInputDevice, cable: Int, channel: Int, pressure: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiPitchWheel(sender: MidiInputDevice, cable: Int, channel: Int, amount: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiOutputDeviceAttached(midiOutputDevice: MidiOutputDevice) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onDeviceDetached(usbDevice: UsbDevice) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiOutputDeviceDetached(midiOutputDevice: MidiOutputDevice) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiSingleByte(sender: MidiInputDevice, cable: Int, byte1: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onDeviceAttached(usbDevice: UsbDevice) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiSongSelect(sender: MidiInputDevice, cable: Int, song: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiSongPositionPointer(sender: MidiInputDevice, cable: Int, position: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiTuneRequest(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiTimingClock(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiStart(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiContinue(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiStop(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiActiveSensing(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiReset(sender: MidiInputDevice, cable: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    override fun onMidiTimeCodeQuarterFrame(sender: MidiInputDevice, cable: Int, timing: Int) {
        TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
    }

    companion object {
        private var instance: MIDIEngineKitkat? = null

        // we share the instance of MIDIEngineKitkat to prevent system crashes on nexus5
        fun getInstance(context: Context): MIDIEngineKitkat {
            if (instance != null) {
                // it does not matter if context has changed
                // because it is only used for accessing the USB systemservice

                instance?.onMIDIDeviceChanged?.invoke(instance!!.midiInputDevices.toMIDIDeviceArray())
                return instance!!
            }

            instance = MIDIEngineKitkat(context)
            return instance!!
        }
    }

    override var onMIDIDeviceChanged: MIDIDeviceChangedCallback? = null
    override var onMIDIMessageReceived: MIDIMessageReceivedCallback? = null

    private val midiInputDevices = ArrayList<MidiInputDevice>()

    override fun onMidiInputDeviceAttached(midiInputDevice: MidiInputDevice) {
        midiInputDevices.add(midiInputDevice)
        onMIDIDeviceChanged?.invoke(midiInputDevices.toMIDIDeviceArray())
    }

    override fun onMidiInputDeviceDetached(midiInputDevice: MidiInputDevice) {
        if (midiInputDevices.remove(midiInputDevice))
            onMIDIDeviceChanged?.invoke(midiInputDevices.toMIDIDeviceArray())
        else
            println("Warning: " + midiInputDevice.toString() + " was not found in list (and therefore could not be removed)")
    }

    override fun onMidiNoteOff(midiInputDevice: MidiInputDevice, cable: Int, channel: Int, note: Int, velocity: Int) {
        val noteOffStatus = 0b10000000 or channel // bitwise or
        val msg = byteArrayOf(noteOffStatus.toByte(), note.toByte(), velocity.toByte())
        onMIDIMessageReceived?.invoke(msg, 0, msg.size, System.nanoTime())
    }

    override fun onMidiNoteOn(midiInputDevice: MidiInputDevice, cable: Int, channel: Int, note: Int, velocity: Int) {
        val noteOnStatus = 0b10010000 or channel  // bitwise or
        val msg = byteArrayOf(noteOnStatus.toByte(), note.toByte(), velocity.toByte())
        onMIDIMessageReceived?.invoke(msg, 0, msg.size, System.nanoTime())
    }

    override fun onMidiControlChange(midiInputDevice: MidiInputDevice, cable: Int, channel: Int, control: Int, value: Int) {
        val controlChangeStatus = 0b10110000 or channel  // bitwise or
        val msg = byteArrayOf(controlChangeStatus.toByte(), control.toByte(), value.toByte())
        onMIDIMessageReceived?.invoke(msg, 0, msg.size, System.nanoTime())
    }

    init {
        // in order to be able to use the SDL threads looper, we need to call .prepare()
        // else error: "Can't create handler inside thread that has not called Looper.prepare()"
        if (Looper.myLooper() == null) {
            Looper.prepare()
        }

        this.open()
    }
}

private fun MidiInputDevice.toMIDIDevice() : MIDIDevice = MIDIDevice(
    manufacturer = this.manufacturerName ?: "Unknown Manufacturer",
    model = this.productName ?: "Unknown Model",
    uniqueID = this.usbDevice.deviceId
)

private fun ArrayList<MidiInputDevice>.toMIDIDeviceArray() : Array<MIDIDevice> = this.map(MidiInputDevice::toMIDIDevice).toTypedArray()