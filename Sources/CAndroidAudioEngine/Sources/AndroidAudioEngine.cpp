#include "AndroidAudioEngine.h"
#include "Superpowered/SuperpoweredAndroidAudioIO.h"

#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_AndroidConfiguration.h>

#include <limits.h>
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

void (*onAudioData)(float *, int, int, void *);
void (*onSamplerateChanged)(int, void *);
void *audioEngineContext;

static bool audioProcessing(void *clientdata, short int *audioInputOutput, int numberOfSamples, int currentSamplerate)
{
    // First of all, numberOfSamples is __per channel__
    // Secondly, audioProcessing ALWAYS receives 16-bit Stereo Interleaved samples
    // The left & right input channels contained exactly the same data in our tests

    // We now do this in the loop below to save the dependency on libSuperpowered.a:
    // SuperpoweredShortIntToFloat(audioInputOutput, inputBufferFloat, numberOfSamples);

    // Convert the 16-bit integer samples to 32-bit floating point, then:
    // De-interleave, discarding (identical) samples from the Right channel.
    for (short i = 0; i < numberOfSamples * 2; i += 2)
    {
        // convert a signed short int in the range between −32.768 .. 32.767 into a float in the range between -1 .. 1
        float sample = (float)audioInputOutput[i] / ((float)SHRT_MAX);
        monoBufferFloat[i / 2] = sample;
        // XXX: would be more correct:
        // monoBufferFloat[i / 2] = (inputBufferFloat[i] + inputBufferFloat[i+1] / 2)
    }

    onAudioData(monoBufferFloat, numberOfSamples, currentSamplerate, audioEngineContext);

    return true; // XXX should actually return false to output silence ??
}

void CAndroidAudioEngine_setOnAudioData(void (*funcpntr)(float *, int, int, void *), void *context)
{
    onAudioData = funcpntr;
    audioEngineContext = context;
}

void CAndroidAudioEngine_initialize(int desiredSamplerate, int desiredBufferSize)
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
        true,                               // enableInput
        false,                              // enableOutput
        audioProcessing,                    // callback
        NULL,                               // clientData
        SL_ANDROID_RECORDING_PRESET_GENERIC,// inputStreamType
        desiredBufferSize * 2               // latencySamples
    );

    // audioIO immediatly runs after initialziation, so stop it right away
    audioIO->stop();
}

void CAndroidAudioEngine_start()
{
    if (audioIO != NULL)
        audioIO->start();
}

void CAndroidAudioEngine_stop()
{
    if (audioIO != NULL)
        audioIO->stop();
}

bool CAndroidAudioEngine_isInitialized()
{
    return (audioIO != NULL);
}

void CAndroidAudioEngine_deinitialize()
{
    CAndroidAudioEngine_stop();
    delete(audioIO);
    free(inputBufferFloat);
    free(monoBufferFloat);
}

#ifdef __cplusplus
}
#endif
