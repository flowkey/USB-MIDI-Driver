cmake_minimum_required(VERSION 3.16)
project(NoteDetection Swift CXX)

set(CMAKE_Swift_MODULE_DIRECTORY ${CMAKE_BINARY_DIR}/swift)

add_library(CAndroidAudioEngine STATIC
    Sources/CAndroidAudioEngine/Sources/AndroidAudioEngine.cpp
    Sources/CAndroidAudioEngine/Sources/Superpowered/SuperpoweredAndroidAudioIO.cpp)

target_include_directories(CAndroidAudioEngine PRIVATE
    ${NoteDetection_SOURCE_DIR}/Sources/CAndroidAudioEngine/include)

# Point to modulemap (swiftc searches automatically in /include)
set_target_properties(CAndroidAudioEngine PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES ${NoteDetection_SOURCE_DIR}/Sources/CAndroidAudioEngine)


add_library(NoteDetection SHARED
    Sources/NoteDetection/AudioHelper.swift
    Sources/NoteDetection/LightControllerProtocol.swift
    Sources/NoteDetection/NoteRange.swift
    Sources/NoteDetection/StreamLightController.swift
    Sources/NoteDetection/AndroidActivityContext.swift
    Sources/NoteDetection/PlatformAndroid.swift
    Sources/NoteDetection/YamahaMessages.swift
    Sources/NoteDetection/MIDIEngine.swift
    Sources/NoteDetection/RecordAudioPermission.swift
    Sources/NoteDetection/AudioEngineAndroid.swift
    Sources/NoteDetection/AudioNoteDetection.swift
    Sources/NoteDetection/MIDIMessage.swift
    Sources/NoteDetection/YamahaLights.swift
    Sources/NoteDetection/MIDIEngineAndroid+send.swift
    Sources/NoteDetection/MIDINumber.swift
    Sources/NoteDetection/NoteDetection.swift
    Sources/NoteDetection/MIDIEngineAndroid.swift
    Sources/NoteDetection/FilterBank.swift
    Sources/NoteDetection/MIDINoteDetection.swift
    Sources/NoteDetection/ChromaVector.swift
    Sources/NoteDetection/MusicalNote.swift
    Sources/NoteDetection/ProcessedAudio.swift
    Sources/NoteDetection/DetectableNoteEvent.swift
    Sources/NoteDetection/Filter.swift
    Sources/NoteDetection/PitchDetection.swift
    Sources/NoteDetection/SpectralFlux.swift
    Sources/NoteDetection/MIDIDevice.swift
    Sources/NoteDetection/LightControlStatus.swift
    Sources/NoteDetection/MIDIOutConnectionAndroid.swift
    Sources/NoteDetection/FlowMathAndroid.swift
    Sources/NoteDetection/OnsetDetection.swift
    Sources/NoteDetection/AudioEngine.swift
    Sources/NoteDetection/RegularLightController.swift
)

set_target_properties(NoteDetection PROPERTIES
  INTERFACE_LINK_DIRECTORIES $<TARGET_LINKER_FILE_DIR:UIKit>
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_Swift_MODULE_DIRECTORY}
)

if(NOT TARGET JNI)
    # if Notedetection is build standalone (without UIKit) we have to add JNI
    add_subdirectory(../UIKit/swift-jni "swift-jni")
endif()

target_link_libraries(NoteDetection 
    PRIVATE
        JNI 
    PUBLIC
        CAndroidAudioEngine
)

# We have a dependency on `SDL_AndroidGetActivity` in AndroidActivityContext.swift:
# Note: this explicit linking is only required for Android 5.0
#target_link_libraries(NoteDetection PRIVATE SDL)
