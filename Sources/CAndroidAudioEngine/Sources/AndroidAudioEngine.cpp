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

// use of static for a top level variable means that source code in other files
// that are part of the project cannot access the variable
static SuperpoweredAndroidAudioIO *audioIO;

float *monoBufferFloat;
float *inputBufferFloat;

void (*onAudioData)(float *audioBuffer, int numberOfSamples, int sampleRate, void *context);
void *audioEngineContext;

const float SHORTMAX = ((float)SHRT_MAX);

static bool audioProcessing(void *clientdata, short int *audioInputOutput, int numberOfSamples, int currentSamplerate)
{
    // First of all, numberOfSamples is __per channel__
    // Secondly, audioProcessing ALWAYS receives 16-bit Stereo Interleaved samples
    // The left & right input channels contained exactly the same data in our tests

    // Convert the 16-bit integer samples to 32-bit floating point, then:
    // De-interleave, discarding (identical) samples from the Right channel.
    for (short i = 0; i < numberOfSamples * 2; i += 2)
    {
        // convert a signed short int in the range between −32.768 .. 32.767 into a float in the range between -1 .. 1
        monoBufferFloat[i / 2] = ((float)audioInputOutput[i]) / SHORTMAX;
        // XXX: would be more correct:
        // monoBufferFloat[i / 2] = (inputBufferFloat[i] + inputBufferFloat[i+1] / 2)
    }

    onAudioData(monoBufferFloat, numberOfSamples, currentSamplerate, audioEngineContext);

    return false;
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
    monoBufferFloat = (float *)malloc(desiredBufferSize * sizeof(float));
    inputBufferFloat = (float *)malloc(desiredBufferSize * sizeof(float) * 2 + 128);

    audioIO = new SuperpoweredAndroidAudioIO(
        desiredSamplerate,
        desiredBufferSize,
        true,                                // enableInput
        false,                               // enableOutput
        audioProcessing,                     // callback
        NULL,                                // clientData
        SL_ANDROID_RECORDING_PRESET_GENERIC, // inputStreamType
        -1,                                  // outputstreamType
        0                                    // latencySamples, works only if input and output are enabled
    );

    // audioIO immediatly runs after initialziation, stop it
    // right away because caller does not expect it to be running
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
    LOGI("deiniting CAndroidAudioEngine");
    CAndroidAudioEngine_stop();
    delete(audioIO);
    free(inputBufferFloat);
    free(monoBufferFloat);
}

#ifdef __cplusplus
}
#endif
