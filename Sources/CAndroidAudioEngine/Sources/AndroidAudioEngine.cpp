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

// top-level static in c means fileprivate for the linker
static SuperpoweredAndroidAudioIO *audioIO;

static float *monoBufferFloat = NULL;

static void (*onAudioData)(float *audioBuffer, int numberOfSamples, int sampleRate, void *context);
static void *audioEngineContext;

static const float SHORTMAX = ((float)SHRT_MAX);

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
        // monoBufferFloat[i / 2] = ((float)audioInputOutput[i] + (float)audioInputOutput[i + 1]) / SHORTMAX;
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

    audioIO = new SuperpoweredAndroidAudioIO(
        desiredSamplerate,
        desiredBufferSize,
        true,                                          // enableInput
        false,                                         // enableOutput
        audioProcessing,                               // callback
        NULL,                                          // clientData
        SL_ANDROID_RECORDING_PRESET_VOICE_RECOGNITION, // inputStreamType
        -1,                                            // outputstreamType
        desiredBufferSize * 2                          // latencySamples
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
    CAndroidAudioEngine_stop();
    delete audioIO;
    audioIO = NULL;
    audioEngineContext = NULL;
    if (monoBufferFloat) {
        free(monoBufferFloat);
        monoBufferFloat = NULL;
    }
}

#ifdef __cplusplus
}
#endif
