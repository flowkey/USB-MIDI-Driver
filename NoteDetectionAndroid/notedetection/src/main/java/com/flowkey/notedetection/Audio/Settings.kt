package com.flowkey.notedetection.Audio

import android.content.Context
import android.media.AudioManager
import android.content.Context.AUDIO_SERVICE
import android.content.pm.PackageManager

fun getFastAudioPathSampleRate(ctx: Context): Double {
    val audioManager = ctx.getSystemService(AUDIO_SERVICE) as AudioManager
    val sampleRateStr = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_SAMPLE_RATE)
    return sampleRateStr.toDouble()
}

fun getFastAudioPathBufferSize(ctx: Context): Int {
    val audioManager = ctx.getSystemService(AUDIO_SERVICE) as AudioManager
    val bufferSizeStr = audioManager.getProperty(AudioManager.PROPERTY_OUTPUT_FRAMES_PER_BUFFER)
    return bufferSizeStr.toInt()
}

fun hasLowLatencyFeature(ctx: Context): Boolean {
    return ctx.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_LOW_LATENCY)
}

fun hasProAudioFeature(ctx: Context): Boolean {
    return ctx.packageManager.hasSystemFeature(PackageManager.FEATURE_AUDIO_PRO)
}