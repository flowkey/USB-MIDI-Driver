package com.flowkey.notedetection.midi

import android.content.Context
import android.media.midi.*
import android.media.midi.MidiManager.DeviceCallback
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.support.annotation.RequiresApi
import java.io.IOException

@RequiresApi(api = Build.VERSION_CODES.M)
internal class MIDIEngineM(context: Context) : MIDIEngine {

    override var onMIDIDeviceChanged: MIDIDeviceChangedCallback? = null
    override var onMIDIMessageReceived: MIDIMessageReceivedCallback? = null

    // we use the mainLooper instead of the currents threads .myLooper()
    // otherwise deviceCallback won't fire
    private val handler = Handler(Looper.getMainLooper())
    private val midiManager = context.getSystemService(Context.MIDI_SERVICE) as MidiManager

    private val deviceCallback = object: DeviceCallback() {
        override fun onDeviceAdded(deviceInfo: MidiDeviceInfo) {
            midiManager.openDevice(deviceInfo, connectOutputPortsToReceiver, handler)
            onMIDIDeviceChanged?.invoke(midiManager.devices.toMIDIDeviceArray())
        }
        override fun onDeviceRemoved(device: MidiDeviceInfo) {
            onMIDIDeviceChanged?.invoke(midiManager.devices.toMIDIDeviceArray())
        }
        override fun onDeviceStatusChanged(status: MidiDeviceStatus) {
            onMIDIDeviceChanged?.invoke(midiManager.devices.toMIDIDeviceArray())
        }
    }

    private val connectOutputPortsToReceiver: (MidiDevice) -> Unit = { device ->
        (0..device.info.outputPortCount - 1).map { device.openOutputPort(it).connect(midiReceiver) }
    }

    private val midiReceiver = object: MidiReceiver() {
        @Throws(IOException::class)
        override fun onSend(msg: ByteArray, offset: Int, count: Int, timestamp: Long) {
            onMIDIMessageReceived?.invoke(msg, offset, count, timestamp)
        }
    }

    init {
        midiManager.registerDeviceCallback(deviceCallback, handler)
        midiManager.devices.forEach { midiManager.openDevice(it, connectOutputPortsToReceiver, handler) }
    }
}

@RequiresApi(Build.VERSION_CODES.M)
private fun MidiDeviceInfo.toMIDIDevice() : MIDIDevice = MIDIDevice(
    model = this.properties.getString(MidiDeviceInfo.PROPERTY_NAME) ?: "MIDI Device",
    manufacturer = this.properties.getString(MidiDeviceInfo.PROPERTY_MANUFACTURER) ?: "",
    uniqueID = this.id
)

private fun Array<MidiDeviceInfo>.toMIDIDeviceArray() : Array<MIDIDevice> = this.map(MidiDeviceInfo::toMIDIDevice).toTypedArray()


//        private val btMIDIScanner = BluetoothAdapter.getDefaultAdapter().bluetoothLeScanner
//
//        val midiScanFilterBuilder = ScanFilter.Builder()
//        midiScanFilterBuilder.setServiceUuid(ParcelUuid(UUID.fromString("03B80E5A-EDE8-4B33-A751-6CE34EC4C700")))
//        val scanFilters: List<ScanFilter> = listOf(midiScanFilterBuilder.build())
//        btMIDIScanner.startScan(scanFilters, ScanSettings.Builder().build(), object : ScanCallback() {
//            override fun onScanResult(callbackType: Int, result: ScanResult?) {
//                val address = result?.device?.address
//                val name = result?.device?.name
//
//                val btDevice = result?.device1
//                if (btDevice != null) { midiManager.openBluetoothDevice(btDevice, connectOutputPortsToReceiver, Handler()) }
//            }
//        })