package com.flowkey.notedetection.Audio

import android.content.Context
import android.media.AudioManager
import android.content.Context.AUDIO_SERVICE
import android.content.pm.PackageManager

fun getFastAudioPathSampleRate(context: Object): Double {
    val ctx = context as Context
    val audioManager = ctx.getSystemService(AUDIO_SERVICE) as AudioManager
    val sampleRateStr = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE)
    return sampleRateStr.toDouble()
}

fun getFastAudioPathBufferSize(context: Object): Int {
    val ctx = context as Context
    val audioManager = ctx.getSystemService(AUDIO_SERVICE) as AudioManager
    val bufferSizeStr = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER)
    return bufferSizeStr.toInt()
}

fun hasLowLatencyFeature(context: Object): Boolean {
    val ctx = context as Context
    return ctx.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY)
}

fun hasProAudioFeature(context: Object): Boolean {
    val ctx = context as Context
    return ctx.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)
}