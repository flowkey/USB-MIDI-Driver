#ifdef __cplusplus
extern "C" {
#endif

void CAndroidAudioEngine_initialize(int desiredSamplerate, int desiredBufferSize);
void CAndroidAudioEngine_start();
void CAndroidAudioEngine_stop();
int CAndroidAudioEngine_getSamplerate();
void CAndroidAudioEngine_setOnAudioData(void (*funcpntr)(float *, int, void *), void *);
void CAndroidAudioEngine_setOnSamplerateChange(void (*funcpntr)(int, void *), void *);

#ifdef __cplusplus
}
#endif
