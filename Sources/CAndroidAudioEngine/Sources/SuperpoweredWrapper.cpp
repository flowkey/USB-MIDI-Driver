//
// Created by flowing erik on 18.11.15.
//

#include "SuperpoweredWrapper.h"
#include "Superpowered/SuperpoweredAndroidAudioIO.h"
#include "Superpowered/SuperpoweredSimple.h"
#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <android/log.h>
#include <climits>

#define  LOG_TAG    "NATIVE_AUDIO_ENGINE"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)

static SuperpoweredAndroidAudioIO *audioIO;

float *monoBufferFloat;
float *inputBufferFloat;

static bool audioProcessing(void *clientdata, short int *audioInputOutput, int numberOfSamples, int samplerate) {
    // First of all, numberOfSamples is __per channel__
    // Secondly, audioProcessing ALWAYS receives 16-bit Stereo Interleaved samples
    // The left & right input channels contained exactly the same data in our tests

    // Convert the 16-bit integer samples to 32-bit floating point.
    SuperpoweredShortIntToFloat(audioInputOutput, inputBufferFloat, numberOfSamples);

    // De-interleave, discarding (identical) samples from the Right channel.
    for (short i = 0; i < numberOfSamples * 2; i += 2) {
        monoBufferFloat[i / 2] = inputBufferFloat[i];
    }

    NativePitchDetection_audioCallback(monoBufferFloat, numberOfSamples);
    return true;
}


void initAudioEngine(int samplerate, int buffersize) {

    if (audioIO != NULL)
        return;

    // Prepare an intermediate buffer for Int-Float conversion.
    // This buffer never gets freed, but it's not such a big deal if it just dies with the app ( I THINK )
    // XXX: if we kill audioIO at some point via unloadSource, we should also dealloc inputBufferFloat
    monoBufferFloat = (float *)malloc(buffersize * sizeof(float));
    inputBufferFloat = (float *)malloc(buffersize * sizeof(float) * 2 + 128);

    jobject globalJobj = env->NewGlobalRef(self); // XXX: this is never freed either
    NativePitchDetection_setupAudioProcessor(globalJobj, (int) samplerate);

    // Start audio input/output.
    audioIO = new SuperpoweredAndroidAudioIO(samplerate, buffersize, true, false, audioProcessing, NULL, SL_ANDROID_RECORDING_PRESET_GENERIC, buffersize * 2);
    audioIO->stop(); // we only want to init the stream, so stop it straight away.
}

void startAudioEngine() {

    if (audioIO != NULL)
        audioIO->start();

}

void stopAudioEngine() {

    if (audioIO != NULL)
        audioIO->stop();

}
