#ifdef __cplusplus
extern "C" {
#endif

void initialize(int desiredSamplerate, int desiredBufferSize);
void start();
void stop();
int getSamplerate();
void setOnAudioData(void (*funcpntr)(float*, int, void*), void*);

#ifdef __cplusplus
}
#endif
