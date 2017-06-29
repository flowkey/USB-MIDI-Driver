#include "../include/AndroidAudioEngine.h"
#include "SuperpoweredAndroidAudioIO.h"
#include "SuperpoweredSimple.h"

#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

#include <stdlib.h>
#include <android/log.h>

#define LOG_TAG "ANDROID_AUDIO_ENGINE"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

#ifdef __cplusplus
extern "C" {
#endif

static SuperpoweredAndroidAudioIO *audioIO;
float *monoBufferFloat;
float *inputBufferFloat;
void (*onAudioData)(float*, int, void*);
void *onAudioDataContext;

    static bool
    audioProcessing(void *clientdata, short int *audioInputOutput, int numberOfSamples, int samplerate)
{
    // First of all, numberOfSamples is __per channel__
    // Secondly, audioProcessing ALWAYS receives 16-bit Stereo Interleaved samples
    // The left & right input channels contained exactly the same data in our tests

    // Convert the 16-bit integer samples to 32-bit floating point.
    SuperpoweredShortIntToFloat(audioInputOutput, inputBufferFloat, numberOfSamples);

    // De-interleave, discarding (identical) samples from the Right channel.
    for (short i = 0; i < numberOfSamples * 2; i += 2)
    {
        monoBufferFloat[i / 2] = inputBufferFloat[i];
    }

    onAudioData(monoBufferFloat, numberOfSamples, onAudioDataContext);
    return true;
}

void setOnAudioData(void (*funcpntr)(float *, int, void *), void *context)
{
    onAudioData = funcpntr;
    onAudioDataContext = context;
}

void initialize(int desiredSamplerate, int desiredBufferSize)
{
    if (audioIO != NULL)
        return;

    // Prepare an intermediate buffer for Int-Float conversion.
    // This buffer never gets freed, but it's not such a big deal if it just dies with the app ( I THINK )
    // XXX: if we kill audioIO at some point via unloadSource, we should also dealloc inputBufferFloat
    monoBufferFloat = (float *)malloc(desiredBufferSize * sizeof(float));
    inputBufferFloat = (float *)malloc(desiredBufferSize * sizeof(float) * 2 + 128);

    audioIO = new SuperpoweredAndroidAudioIO(
        desiredSamplerate,
        desiredBufferSize,
        true,  // enableInput
        false, // enableOutput
        audioProcessing,
        NULL,                                // clientData
        SL_ANDROID_RECORDING_PRESET_GENERIC, // inputStreamType
        desiredBufferSize * 2                // latencySamples
        );

    // we only want to init the stream, so stop it straight away.
    audioIO->stop();
}

void start()
{
    if (audioIO != NULL)
        audioIO->start();
}

void stop()
{
    if (audioIO != NULL)
        audioIO->stop();
}

int getSamplerate()
{
    return 44100;
}

#ifdef __cplusplus
}
#endif
