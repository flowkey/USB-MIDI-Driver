LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
SRC_DIR := $(LOCAL_PATH)/Sources/Superpowered
LOCAL_MODULE    := Superpowered
LOCAL_SRC_FILES := $(SRC_DIR)/libSuperpoweredAndroidARM.a
LOCAL_EXPORT_C_INCLUDES := $(SRC_DIR)
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := AudioEngine
SRC_DIR := $(LOCAL_PATH)/Sources
LOCAL_CFLAGS := -I$(SRC_DIR)/include -I$(SRC_DIR)/Superpowered
LOCAL_SRC_FILES := $(SRC_DIR)/AndroidAudioEngine.cpp $(SRC_DIR)/Superpowered/SuperpoweredAndroidAudioIO.cpp
LOCAL_CFLAGS += -O3
LOCAL_LDLIBS := -llog -landroid -lOpenSLES
LOCAL_STATIC_LIBRARIES := Superpowered
include $(BUILD_SHARED_LIBRARY)
