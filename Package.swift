// swift-tools-version:3.1
// Package only intended to work for Linux/Android

import PackageDescription

let package = Package(
    name: "NoteDetection",
    targets: [
        Target(name: "NoteDetection", dependencies: ["CAndroidAudioEngine"]),
        Target(name: "CAndroidAudioEngine", dependencies: [])
    ],
    exclude: [
        // exclude all iOS-only files
        "Sources/NoteDetection/FlowMathApple.swift",
        "Sources/NoteDetection/PlatformApple.swift",
        "Sources/NoteDetection/PlatformAndroid.old.swift",
        "Sources/NoteDetection/NoteDetectionIOS.swift",
        "Sources/NoteDetection/AudioEngineIOS.swift",
        "Sources/NoteDetection/AudioUnitExtensions.swift",
        "Sources/NoteDetection/MIDIEngineIOS.swift",
        "Sources/NoteDetection/MIDIEngine+Debug.swift",
        "Sources/NoteDetection/MIDIMessage+MIDIPacket.swift",
        "Sources/NoteDetection/MIDIObjectRef.swift",
        "Sources/NoteDetection/OSStatus+LocalizedError.swift",

        // exclude CAndroidAudioEngine (using prebuilt library)
        "Sources/CAndroidAudioEngine/Sources/AndroidAudioEngine.cpp",
        "Sources/CAndroidAudioEngine/Sources/Superpowered/SuperpoweredAndroidAudioIO.cpp"
    ]
)
