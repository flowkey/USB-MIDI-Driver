package com.flowkey.notedetection.midi

import android.content.Context
import android.content.pm.PackageManager.FEATURE_MIDI
import android.os.Build.VERSION.SDK_INT
import android.os.Build.VERSION_CODES.M
import java.util.*

// wraps MIDI engine for Android 4 (Kitkat) or 6 (Marshmallow)
@android.support.annotation.Keep
class ApiIndependentMIDIEngine(context: Context) {
    private val midiEngine: MIDIEngine

    init {
        // val hasMIDISystemFeature = SDK_INT >= M && context.packageManager.hasSystemFeature(FEATURE_MIDI)

        midiEngine = MIDIEngineKitkat.getInstance(context) //if (hasMIDISystemFeature) MIDIEngineM(context) else
        midiEngine.onMIDIDeviceChanged = { devices ->
            nativeMidiDeviceCallback(devices)
        }

        midiEngine.onMIDIMessageReceived = { msg, offset, count, timestamp ->
            nativeMidiMessageCallback(
                    midiData  = Arrays.copyOfRange(msg, offset, offset + count),
                    timestamp = timestamp
            )
        }
    }

    external fun nativeMidiDeviceCallback(devices: Array<MIDIDevice>)
    external fun nativeMidiMessageCallback(midiData: ByteArray, timestamp: Long)
}