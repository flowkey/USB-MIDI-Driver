#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

void CAndroidAudioEngine_initialize(int desiredSamplerate, int desiredBufferSize);
void CAndroidAudioEngine_deinitialize();
void CAndroidAudioEngine_start();
void CAndroidAudioEngine_stop();
void CAndroidAudioEngine_setOnAudioData(void (*funcpntr)(float *, int, int, void *), void *);
bool CAndroidAudioEngine_isInitialized();

#ifdef __cplusplus
}
#endif
